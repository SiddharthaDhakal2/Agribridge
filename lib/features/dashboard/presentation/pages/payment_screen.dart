import 'dart:async';

import 'package:agribridge/core/api/api_client.dart';
import 'package:agribridge/core/api/api_endpoint.dart';
import 'package:agribridge/core/services/storage/user_session_service.dart';
import 'package:agribridge/features/dashboard/presentation/pages/button_navigation.dart';
import 'package:agribridge/features/dashboard/presentation/state/cart_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final double subtotal;
  final double deliveryFee;
  final double total;

  const PaymentScreen({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen>
    with WidgetsBindingObserver {
  static const int _maxVerificationAttempts = 20;
  static const Duration _verificationInterval = Duration(seconds: 3);

  _PaymentMethod? _selectedMethod;

  bool _isSubmitting = false;
  bool _isVerifying = false;
  String? _pendingPidx;
  String? _pendingOrderId;
  int _verificationAttempts = 0;
  Timer? _verificationTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _pendingPidx != null &&
        !_isVerifying) {
      unawaited(_verifyPendingPayment(silent: true));
      _startAutoVerification();
    }
  }

  void _startAutoVerification({bool resetAttempts = false}) {
    if (_pendingPidx == null || _pendingPidx!.isEmpty) return;
    if (resetAttempts) {
      _verificationAttempts = 0;
    }

    _verificationTimer?.cancel();
    _verificationTimer = Timer.periodic(_verificationInterval, (timer) async {
      if (!mounted || _pendingPidx == null || _pendingPidx!.isEmpty) {
        timer.cancel();
        return;
      }

      if (_verificationAttempts >= _maxVerificationAttempts) {
        timer.cancel();
        return;
      }

      if (_isVerifying) return;

      _verificationAttempts += 1;
      final isPaid = await _verifyPendingPayment(silent: true);
      if (isPaid) {
        timer.cancel();
      }
    });
  }

  String _formatPrice(double value) {
    if (value % 1 == 0) return value.toStringAsFixed(0);
    return value.toStringAsFixed(2);
  }

  void _showInfoSnack(String message, {bool isWarning = false}) {
    if (!mounted) return;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isWarning
            ? (isDarkMode
                  ? const Color(0xFF3A2F1F)
                  : const Color(0xFFFFF4E5))
            : (isDarkMode
                  ? const Color(0xFF243126)
                  : const Color(0xFFEFF8F1)),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          message,
          style: TextStyle(
            color: isWarning
                ? (isDarkMode
                      ? const Color(0xFFFFD9A8)
                      : const Color(0xFF7A2E00))
                : (isDarkMode
                      ? const Color(0xFFB8F5C6)
                      : const Color(0xFF14532D)),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _extractErrorMessage(
    Object error, {
    String fallback = 'Payment request failed.',
  }) {
    if (error is StateError) return error.message;
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message']?.toString().trim();
        if (message != null && message.isNotEmpty) return message;
      }
      if (error.message != null && error.message!.trim().isNotEmpty) {
        return error.message!.trim();
      }
    }
    return fallback;
  }

  Map<String, dynamic> _buildOrderPayload() {
    final cartItems = ref.read(cartProvider);
    if (cartItems.isEmpty) {
      throw StateError('Your cart is empty.');
    }

    final userSessionService = ref.read(userSessionServiceProvider);
    final customerName = (userSessionService.getCurrentUserFullName() ?? '')
        .trim();
    final customerEmail = (userSessionService.getCurrentUserEmail() ?? '')
        .trim();
    final phone = (userSessionService.getCurrentUserPhoneNumber() ?? '').trim();
    final address = (userSessionService.getCurrentUserAddress() ?? '').trim();

    if (customerName.isEmpty ||
        customerEmail.isEmpty ||
        phone.isEmpty ||
        address.isEmpty) {
      throw StateError('Please complete delivery information before payment.');
    }

    final items = cartItems
        .map(
          (item) => {
            'productId': item.id,
            'name': item.name,
            'price': item.price,
            'quantity': item.quantity,
            'total': item.price * item.quantity,
          },
        )
        .toList();

    return {
      'items': items,
      'total': widget.total,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'phone': phone,
      'address': address,
    };
  }

  Future<void> _startPayment() async {
    if (_selectedMethod == null) {
      _showInfoSnack('Please choose a payment method.', isWarning: true);
      return;
    }

    if (_selectedMethod != _PaymentMethod.khalti) {
      _showInfoSnack(
        'Selected payment method is not available yet.',
        isWarning: true,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      final payload = _buildOrderPayload();

      final response = await apiClient.post(
        ApiEndpoints.khaltiInitiatePayment,
        data: payload,
      );

      if (response.data is! Map<String, dynamic>) {
        throw StateError('Invalid payment response from server.');
      }

      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) {
        final message =
            body['message']?.toString() ?? 'Failed to initiate payment.';
        throw StateError(message);
      }

      final data = body['data'];
      if (data is! Map<String, dynamic>) {
        throw StateError('Invalid payment data from server.');
      }

      final pidx = (data['pidx']?.toString() ?? '').trim();
      final orderId = (data['orderId']?.toString() ?? '').trim();
      final paymentUrl = (data['paymentUrl']?.toString() ?? '').trim();

      if (pidx.isEmpty || paymentUrl.isEmpty) {
        throw StateError('Payment initialization failed.');
      }

      final paymentUri = Uri.tryParse(paymentUrl);
      if (paymentUri == null) {
        throw StateError('Invalid Khalti payment URL.');
      }

      setState(() {
        _pendingPidx = pidx;
        _pendingOrderId = orderId.isEmpty ? null : orderId;
      });

      if (!mounted) return;
      final didReachReturnUrl = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => _KhaltiWebCheckoutScreen(
            paymentUri: paymentUri,
            enableDarkMode: Theme.of(context).brightness == Brightness.dark,
          ),
        ),
      );

      if (!mounted) return;

      if (didReachReturnUrl == true) {
        final paid = await _verifyPendingPayment(silent: false);
        if (!paid && _pendingPidx != null) {
          _startAutoVerification(resetAttempts: true);
          _showInfoSnack(
            'Payment is processing. We will verify and update shortly.',
            isWarning: true,
          );
        }
      } else {
        _showInfoSnack(
          'Payment window closed. You can verify from this page.',
          isWarning: true,
        );
        if (_pendingPidx != null) {
          _startAutoVerification(resetAttempts: true);
        }
      }
    } catch (error) {
      _showInfoSnack(
        _extractErrorMessage(error, fallback: 'Failed to start payment.'),
        isWarning: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<bool> _verifyPendingPayment({bool silent = false}) async {
    final pidx = _pendingPidx;
    if (pidx == null || pidx.isEmpty || _isVerifying) return false;

    setState(() {
      _isVerifying = true;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post(
        ApiEndpoints.khaltiVerifyPayment,
        data: {
          'pidx': pidx,
          if (_pendingOrderId != null && _pendingOrderId!.isNotEmpty)
            'orderId': _pendingOrderId,
        },
      );

      if (response.data is! Map<String, dynamic>) {
        throw StateError('Invalid verification response.');
      }

      final body = response.data as Map<String, dynamic>;
      final data = body['data'];
      final paid = data is Map<String, dynamic> && data['paid'] == true;
      final message = body['message']?.toString().trim();

      if (paid) {
        _verificationTimer?.cancel();
        setState(() {
          _pendingPidx = null;
          _pendingOrderId = null;
          _verificationAttempts = 0;
        });
        ref.read(cartProvider.notifier).clear();

        if (!mounted) return true;
        _showInfoSnack('Payment successful. Redirecting to orders...');
        await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const ButtonNavigation(initialIndex: 2),
          ),
          (route) => false,
        );
        return true;
      }

      if (!silent) {
        _showInfoSnack(
          message == null || message.isEmpty
              ? 'Payment not completed yet.'
              : message,
          isWarning: true,
        );
      }
      return false;
    } catch (error) {
      if (!silent) {
        _showInfoSnack(
          _extractErrorMessage(error, fallback: 'Failed to verify payment.'),
          isWarning: true,
        );
      }
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF101828);
    final headerColor = isDarkMode ? Colors.white : const Color(0xFF001739);
    final subtitleColor = isDarkMode ? Colors.white70 : const Color(0xFF334155);
    final summaryBg = isDarkMode ? const Color(0xFF242B28) : const Color(0xFFF7F8FA);
    final summaryBorder = isDarkMode ? Colors.white12 : const Color(0xFFD3D8E0);
    final payButtonColor = isDarkMode ? const Color(0xFF81C784) : const Color(0xFF67C488);
    final payButtonTextColor = isDarkMode ? const Color(0xFF0F1412) : Colors.white;
    final backButtonBg = isDarkMode ? const Color(0xFF2A322D) : const Color(0xFFD4D7DD);
    final backButtonFg = isDarkMode ? Colors.white : const Color(0xFF233349);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Payment',
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                children: [
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment',
                          style: TextStyle(
                            fontSize: 28,
                            color: headerColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Review your payment details',
                          style: TextStyle(
                            fontSize: 16,
                            color: subtitleColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                          decoration: BoxDecoration(
                            color: summaryBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: summaryBorder),
                          ),
                          child: Column(
                            children: [
                              _PaymentAmountRow(
                                label: 'Subtotal',
                                value: 'Rs ${_formatPrice(widget.subtotal)}',
                              ),
                              const SizedBox(height: 10),
                              _PaymentAmountRow(
                                label: 'Delivery Fee',
                                value: 'Rs ${_formatPrice(widget.deliveryFee)}',
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Divider(
                                  color: isDarkMode
                                      ? Colors.white24
                                      : const Color(0xFF2A2A2A),
                                  height: 1,
                                ),
                              ),
                              _PaymentAmountRow(
                                label: 'Total',
                                value: 'Rs ${_formatPrice(widget.total)}',
                                highlight: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose payment method',
                          style: TextStyle(
                            fontSize: 22,
                            color: headerColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _PaymentMethodTile(
                          title: 'Khalti',
                          subtitle: 'Pay instantly using Khalti',
                          trailingText: 'Available',
                          trailingColor: const Color(0xFF00A23D),
                          selected: _selectedMethod == _PaymentMethod.khalti,
                          onTap: () {
                            setState(() {
                              _selectedMethod = _PaymentMethod.khalti;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        _PaymentMethodTile(
                          title: 'eSewa',
                          subtitle: 'Coming soon',
                          trailingText: 'Soon',
                          trailingColor: const Color(0xFF98A2B3),
                          selected: _selectedMethod == _PaymentMethod.esewa,
                          onTap: () {
                            setState(() {
                              _selectedMethod = _PaymentMethod.esewa;
                            });
                          },
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                _selectedMethod == null ||
                                    _isSubmitting ||
                                    _isVerifying
                                ? null
                                : _startPayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: payButtonColor,
                              disabledBackgroundColor: isDarkMode
                                  ? const Color(0xFF5A6B60)
                                  : const Color(0xFFA7DDBB),
                              foregroundColor: payButtonTextColor,
                              disabledForegroundColor: isDarkMode
                                  ? Colors.white60
                                  : Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isSubmitting
                                ? SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        payButtonTextColor,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Pay Now',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                        if (_pendingPidx != null) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _isVerifying
                                  ? null
                                  : () => _verifyPendingPayment(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isDarkMode
                                    ? const Color(0xFFB8F5C6)
                                    : const Color(0xFF14532D),
                                side: BorderSide(
                                  color: isDarkMode
                                      ? const Color(0xFF81C784)
                                      : const Color(0xFF9AD7AE),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isVerifying
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'I have completed payment',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              backgroundColor: backButtonBg,
                              foregroundColor: backButtonFg,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Back to Cart',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _PaymentMethod { khalti, esewa }

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: isDarkMode ? theme.colorScheme.surface : const Color(0xFFEDEFF2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.white12 : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.24 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PaymentAmountRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _PaymentAmountRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
              fontSize: highlight ? 18 : 16,
              fontWeight: highlight ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: TextStyle(
                color: highlight
                    ? (isDarkMode
                          ? const Color(0xFF8EE0A7)
                          : const Color(0xFF00A63F))
                    : (isDarkMode ? Colors.white : const Color(0xFF0F172A)),
                fontSize: highlight ? 19 : 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailingText;
  final Color trailingColor;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.title,
    required this.subtitle,
    required this.trailingText,
    required this.trailingColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF242B28) : const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? (isDarkMode
                      ? const Color(0xFF81C784)
                      : const Color(0xFF67C488))
                : (isDarkMode ? Colors.white12 : const Color(0xFFD3D8E0)),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      color: isDarkMode ? Colors.white : const Color(0xFF001739),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : const Color(0xFF475467),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              trailingText,
              style: TextStyle(
                fontSize: 14,
                color: trailingColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KhaltiWebCheckoutScreen extends StatefulWidget {
  final Uri paymentUri;
  final bool enableDarkMode;

  const _KhaltiWebCheckoutScreen({
    required this.paymentUri,
    required this.enableDarkMode,
  });

  @override
  State<_KhaltiWebCheckoutScreen> createState() =>
      _KhaltiWebCheckoutScreenState();
}

class _KhaltiWebCheckoutScreenState extends State<_KhaltiWebCheckoutScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _returnHandled = false;

  Future<void> _applyBestEffortDarkMode() async {
    if (!widget.enableDarkMode) return;
    try {
      await _controller.runJavaScript('''
(() => {
  if (window.__agribridgeDarkModeApplied) return;
  window.__agribridgeDarkModeApplied = true;

  const style = document.createElement('style');
  style.id = '__agribridge_dark_mode';
  style.textContent = `
    :root { color-scheme: dark !important; }
    html, body { background: #0f1412 !important; color: #e8ece9 !important; }
  `;
  document.head.appendChild(style);
})();
''');
    } catch (_) {
      // Ignore failures from pages that block style/script injection.
    }
  }

  bool _isLikelyReturnUrl(String rawUrl) {
    final uri = Uri.tryParse(rawUrl);
    if (uri == null) return false;

    final host = uri.host.toLowerCase();
    final scheme = uri.scheme.toLowerCase();

    final hasPaymentQuery =
        uri.queryParameters.containsKey('pidx') ||
        uri.queryParameters.containsKey('purchase_order_id') ||
        uri.queryParameters.containsKey('orderId');

    final isKhaltiDomain = host.contains('khalti.com');
    final isLocalhostHost =
        host == 'localhost' || host == '127.0.0.1' || host == '10.0.2.2';
    final isCustomScheme = scheme != 'http' && scheme != 'https';

    if (isCustomScheme) return true;
    if (!isKhaltiDomain && hasPaymentQuery) return true;
    if (isLocalhostHost && (uri.path.contains('/payment') || hasPaymentQuery)) {
      return true;
    }
    return false;
  }

  void _finishAsReturned() {
    if (_returnHandled || !mounted) return;
    _returnHandled = true;
    Navigator.of(context).pop(true);
  }

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
            unawaited(_applyBestEffortDarkMode());
          },
          onNavigationRequest: (request) {
            if (_isLikelyReturnUrl(request.url)) {
              _finishAsReturned();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(widget.paymentUri);

    unawaited(_applyBestEffortDarkMode());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khalti Checkout'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Close'),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
