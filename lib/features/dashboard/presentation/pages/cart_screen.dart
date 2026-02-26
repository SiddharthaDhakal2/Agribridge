import 'package:agribridge/core/services/storage/user_session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'payment_screen.dart';
import '../state/cart_provider.dart';

class CartScreen extends StatelessWidget {
  final VoidCallback? onStartShopping;

  const CartScreen({super.key, this.onStartShopping});

  @override
  Widget build(BuildContext context) {
    return CartScreenBody(onStartShopping: onStartShopping);
  }
}

class CartScreenBody extends ConsumerStatefulWidget {
  final VoidCallback? onStartShopping;

  const CartScreenBody({super.key, this.onStartShopping});

  @override
  ConsumerState<CartScreenBody> createState() => _CartScreenBodyState();
}

class _CartScreenBodyState extends ConsumerState<CartScreenBody> {
  static const int deliveryCharge = 120;

  double _subtotal(List<CartProduct> cartItems) {
    return cartItems.fold(0, (sum, item) => sum + item.price * item.quantity);
  }

  int _activeDeliveryCharge(List<CartProduct> cartItems) {
    return cartItems.isEmpty ? 0 : deliveryCharge;
  }

  String _formatPrice(double value) {
    if (value % 1 == 0) return value.toStringAsFixed(0);
    return value.toStringAsFixed(2);
  }

  Future<void> _openDeliveryInformationSheet({
    required double subtotal,
    required double deliveryFee,
    required double total,
  }) async {
    final userSessionService = ref.read(userSessionServiceProvider);
    final fullName = (userSessionService.getCurrentUserFullName() ?? '').trim();
    final email = (userSessionService.getCurrentUserEmail() ?? '').trim();
    final phone = (userSessionService.getCurrentUserPhoneNumber() ?? '').trim();
    final address = (userSessionService.getCurrentUserAddress() ?? '').trim();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _DeliveryInformationSheet(
          fullName: fullName.isEmpty ? 'User' : fullName,
          email: email,
          initialPhone: phone,
          initialAddress: address,
          subtotal: subtotal,
          deliveryFee: deliveryFee,
          total: total,
          formatPrice: _formatPrice,
          onSubmit: (updatedPhone, updatedAddress) async {
            await userSessionService.setCurrentUserPhoneNumber(updatedPhone);
            await userSessionService.setCurrentUserAddress(updatedAddress);

            if (sheetContext.mounted) {
              Navigator.of(sheetContext).pop();
            }
            if (!mounted) return;

            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PaymentScreen(
                  subtotal: subtotal,
                  deliveryFee: deliveryFee,
                  total: total,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final subtotal = _subtotal(cartItems);
    final activeDeliveryCharge = _activeDeliveryCharge(cartItems);
    final total = subtotal + activeDeliveryCharge;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [CartPalette.pageTop, CartPalette.pageBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: cartItems.isEmpty
                    ? _buildEmptyState()
                    : _buildCartList(cartItems),
              ),
              if (cartItems.isNotEmpty)
                _buildSummaryCard(
                  cartItems: cartItems,
                  subtotal: subtotal,
                  activeDeliveryCharge: activeDeliveryCharge,
                  total: total,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartList(List<CartProduct> cartItems) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        final item = cartItems[index];
        return Dismissible(
          key: ValueKey(item.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) {
            final removedItem = item;
            final removedIndex = index;
            ref.read(cartProvider.notifier).removeItem(removedItem.id);

            final messenger = ScaffoldMessenger.of(context);
            messenger.hideCurrentSnackBar();
            final snackBarController = messenger.showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
                backgroundColor: const Color(0xFFFFF7CC),
                content: Text(
                  '${removedItem.name} removed from cart',
                  style: const TextStyle(
                    color: Color(0xFF2E6E49),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                action: SnackBarAction(
                  label: 'Undo',
                  textColor: const Color(0xFF2E7D32),
                  onPressed: () {
                    ref
                        .read(cartProvider.notifier)
                        .insertItem(removedIndex, removedItem);
                  },
                ),
              ),
            );

            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                snackBarController.close();
              }
            });
          },
          background: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 6),
                Text(
                  'Remove',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          child: CartItemCard(
            item: item,
            onAdd: () =>
                ref.read(cartProvider.notifier).incrementQuantity(item.id),
            onRemove: () =>
                ref.read(cartProvider.notifier).decrementQuantity(item.id),
            formatPrice: _formatPrice,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEFF2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              size: 42,
              color: Color(0xFF9FA6B2),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Add some fresh products to get started!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 18,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: widget.onStartShopping ?? () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B34A),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Start Shopping',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required List<CartProduct> cartItems,
    required double subtotal,
    required int activeDeliveryCharge,
    required double total,
  }) {
    final bool isEmpty = cartItems.isEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: CartPalette.softBorder),
          boxShadow: [
            BoxShadow(
              color: CartPalette.primaryGreen.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: CartPalette.softGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${cartItems.length} item${cartItems.length > 1 ? 's' : ''} selected',
                style: const TextStyle(
                  color: CartPalette.darkGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _SummaryRow(
              label: 'Subtotal',
              value: 'Rs ${_formatPrice(subtotal)}',
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Delivery Charge',
              value: 'Rs ${_formatPrice(activeDeliveryCharge.toDouble())}',
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: CartPalette.softBorder, height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: CartPalette.darkGreen,
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    'Rs ${_formatPrice(total)}',
                    key: ValueKey(total),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: CartPalette.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isEmpty
                    ? null
                    : () {
                        _openDeliveryInformationSheet(
                          subtotal: subtotal,
                          deliveryFee: activeDeliveryCharge.toDouble(),
                          total: total,
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  disabledBackgroundColor: const Color(0xFFAED7B5),
                  foregroundColor: Colors.white,
                  disabledForegroundColor: const Color(0xFF4D6B53),
                  elevation: isEmpty ? 0 : 2,
                  shadowColor: const Color(0xFF2E7D32).withOpacity(0.35),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(
                    color: isEmpty
                        ? const Color(0xFFBFDCC7)
                        : const Color(0xFF1B5E20),
                    width: 1.1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Proceed To Checkout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryInformationSheet extends StatefulWidget {
  final String fullName;
  final String email;
  final String initialPhone;
  final String initialAddress;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String Function(double value) formatPrice;
  final Future<void> Function(String phone, String address) onSubmit;

  const _DeliveryInformationSheet({
    required this.fullName,
    required this.email,
    required this.initialPhone,
    required this.initialAddress,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.formatPrice,
    required this.onSubmit,
  });

  @override
  State<_DeliveryInformationSheet> createState() =>
      _DeliveryInformationSheetState();
}

class _DeliveryInformationSheetState extends State<_DeliveryInformationSheet> {
  static final RegExp _phoneRegex = RegExp(r'^\d{10}$');

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialPhone);
    _addressController = TextEditingController(text: widget.initialAddress);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String hintText,
    bool readOnly = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: readOnly ? const Color(0xFF667085) : const Color(0xFF98A2B3),
      ),
      filled: true,
      fillColor: const Color(0xFFF1F3F6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD92D20), width: 1.1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD92D20), width: 1.2),
      ),
    );
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.onSubmit(
        _phoneController.text.trim(),
        _addressController.text.trim(),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.only(bottom: viewInsetsBottom),
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 10),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.92,
          ),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6F8),
            borderRadius: BorderRadius.circular(22),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Delivery Information',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF101828),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Color(0xFF667085)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Full Name (from profile)',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF344054),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: widget.fullName,
                    enabled: false,
                    style: const TextStyle(
                      color: Color(0xFF475467),
                      fontSize: 18,
                    ),
                    decoration: _inputDecoration(
                      hintText: 'Full Name',
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Email Address (from profile)',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF344054),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: widget.email,
                    enabled: false,
                    style: const TextStyle(
                      color: Color(0xFF475467),
                      fontSize: 18,
                    ),
                    decoration: _inputDecoration(
                      hintText: 'Email Address',
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Phone Number *',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF344054),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: _inputDecoration(
                      hintText: 'Enter 10-digit phone number',
                    ),
                    validator: (value) {
                      final trimmed = (value ?? '').trim();
                      if (trimmed.isEmpty) {
                        return 'Phone number is required';
                      }
                      if (!_phoneRegex.hasMatch(trimmed)) {
                        return 'Phone number must be exactly 10 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Delivery Address *',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF344054),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _addressController,
                    keyboardType: TextInputType.streetAddress,
                    textInputAction: TextInputAction.done,
                    minLines: 3,
                    maxLines: 4,
                    decoration: _inputDecoration(
                      hintText: 'Enter your complete delivery address',
                    ),
                    validator: (value) {
                      final trimmed = (value ?? '').trim();
                      if (trimmed.isEmpty) {
                        return 'Delivery address is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD0D5DD)),
                    ),
                    child: Column(
                      children: [
                        _SummaryRow(
                          label: 'Subtotal',
                          value: 'Rs ${widget.formatPrice(widget.subtotal)}',
                        ),
                        const SizedBox(height: 8),
                        _SummaryRow(
                          label: 'Delivery Fee',
                          value: 'Rs ${widget.formatPrice(widget.deliveryFee)}',
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(color: Color(0xFFD0D5DD), height: 1),
                        ),
                        _SummaryRow(
                          label: 'Total',
                          value: 'Rs ${widget.formatPrice(widget.total)}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF05A43D),
                        disabledBackgroundColor: const Color(0xFF9ED9AF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Continue to Payment',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFD0D5DD),
                        foregroundColor: const Color(0xFF344054),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
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
          ),
        ),
      ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final CartProduct item;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final String Function(double value) formatPrice;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onAdd,
    required this.onRemove,
    required this.formatPrice,
  });

  Widget _buildImageFallback() {
    return Container(
      color: CartPalette.softGreen,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: CartPalette.darkGreen,
      ),
    );
  }

  Widget _buildItemImage() {
    final image = item.image.trim();
    if (image.isEmpty) return _buildImageFallback();

    if (image.toLowerCase().startsWith('http')) {
      return Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildImageFallback(),
      );
    }

    return Image.asset(
      image,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildImageFallback(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double itemTotal = item.price * item.quantity;
    final String itemUnit = item.unit.trim().isEmpty ? 'Kg' : item.unit.trim();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CartPalette.softBorder),
        boxShadow: [
          BoxShadow(
            color: CartPalette.primaryGreen.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(width: 76, height: 76, child: _buildItemImage()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: CartPalette.darkGreen,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: CartPalette.softGreen,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Rs ${formatPrice(item.price)}/$itemUnit',
                    style: const TextStyle(
                      color: CartPalette.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Total: Rs ${formatPrice(itemTotal)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: CartPalette.darkGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: CartPalette.pageTop,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CartPalette.softBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _QuantityActionButton(icon: Icons.remove, onTap: onRemove),
                SizedBox(
                  width: 34,
                  child: Center(
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: CartPalette.darkGreen,
                      ),
                    ),
                  ),
                ),
                _QuantityActionButton(icon: Icons.add, onTap: onAdd),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 18, color: CartPalette.primaryGreen),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            color: CartPalette.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            color: CartPalette.darkGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class CartPalette {
  static const Color primaryGreen = Color(0xFF4CA56F);
  static const Color darkGreen = Color(0xFF2E6E49);
  static const Color accentGreen = Color(0xFF85C9A0);
  static const Color softGreen = Color(0xFFF2FAF5);
  static const Color softBorder = Color(0xFFDDEFE3);
  static const Color pageTop = Color(0xFFFFFFFF);
  static const Color pageBottom = Color(0xFFF5FBF7);
  static const Color textMuted = Color(0xFF6E8174);
}
