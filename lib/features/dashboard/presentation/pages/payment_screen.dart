import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
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
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  _PaymentMethod? _selectedMethod;

  String _formatPrice(double value) {
    if (value % 1 == 0) return value.toStringAsFixed(0);
    return value.toStringAsFixed(2);
  }

  void _showInfoSnack(String message, {bool isWarning = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isWarning
            ? const Color(0xFFFFF4E5)
            : const Color(0xFFEFF8F1),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          message,
          style: TextStyle(
            color: isWarning
                ? const Color(0xFF7A2E00)
                : const Color(0xFF14532D),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _payNow() {
    if (_selectedMethod == null) {
      _showInfoSnack('Please choose a payment method', isWarning: true);
      return;
    }

    if (_selectedMethod != _PaymentMethod.khalti) {
      _showInfoSnack(
        'Selected payment method is not available',
        isWarning: true,
      );
      return;
    }

    _showInfoSnack('Khalti payment integration coming soon');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F5F7),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Payment',
          style: TextStyle(
            color: Color(0xFF101828),
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
                        const Text(
                          'Payment',
                          style: TextStyle(
                            fontSize: 28,
                            color: Color(0xFF001739),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Review your payment details',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F8FA),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFD3D8E0)),
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
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Divider(
                                  color: Color(0xFF2A2A2A),
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
                        const Text(
                          'Choose payment method',
                          style: TextStyle(
                            fontSize: 22,
                            color: Color(0xFF001739),
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
                            _showInfoSnack(
                              'eSewa is not available yet',
                              isWarning: true,
                            );
                          },
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _selectedMethod == null ? null : _payNow,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF67C488),
                              disabledBackgroundColor: const Color(0xFFA7DDBB),
                              foregroundColor: Colors.white,
                              disabledForegroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Pay Now',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFD4D7DD),
                              foregroundColor: const Color(0xFF233349),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEFF2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: const Color(0xFF0F172A),
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
                    ? const Color(0xFF00A63F)
                    : const Color(0xFF0F172A),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF67C488) : const Color(0xFFD3D8E0),
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
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF001739),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF475467),
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
