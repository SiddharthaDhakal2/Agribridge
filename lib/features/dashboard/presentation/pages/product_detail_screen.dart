import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/cart_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  final String imageUrl;
  final String name;
  final String description;
  final double price;
  final String unit;
  final int stockQuantity;
  final String availability;

  const ProductDetailScreen({
    super.key,
    this.productId = '',
    this.imageUrl = '',
    this.name = 'Product',
    this.description = 'No description available.',
    this.price = 0,
    this.unit = 'Kg',
    this.stockQuantity = 0,
    this.availability = 'out-of-stock',
  });

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;

  String get _normalizedAvailability {
    final value = widget.availability.trim().toLowerCase();
    if (value.contains('out')) return 'out-of-stock';
    if (value.contains('low')) return 'low-stock';
    if (value == 'available' || value.contains('in')) return 'in-stock';
    return '';
  }

  String get _stockStatus {
    if (widget.stockQuantity <= 0) return 'out-of-stock';
    final normalized = _normalizedAvailability;
    if (normalized.isNotEmpty) return normalized;
    return 'in-stock';
  }

  bool get _isAvailable => _stockStatus != 'out-of-stock';

  bool get _canIncreaseQty =>
      _isAvailable && _quantity < widget.stockQuantity;

  String get _availabilityText => _stockStatus;

  Color get _availabilityColor {
    switch (_stockStatus) {
      case 'low-stock':
        return const Color(0xFFE67E22);
      case 'out-of-stock':
        return const Color(0xFFC62828);
      case 'in-stock':
      default:
        return const Color(0xFF4E6157);
    }
  }

  String get _unitCaps {
    final value = widget.unit.trim();
    if (value.isEmpty) return 'Kg';
    if (value.toLowerCase() == 'kg') return 'Kg';
    return value;
  }

  String get _unitLower => _unitCaps.toLowerCase();

  double get _totalPrice => widget.price * _quantity;

  void _increaseQty() {
    if (!_canIncreaseQty) return;
    setState(() {
      _quantity++;
    });
  }

  void _decreaseQty() {
    if (_quantity == 1) return;
    setState(() {
      _quantity--;
    });
  }

  String _formatPrice(double value) {
    if (value % 1 == 0) return value.toStringAsFixed(0);
    return value.toStringAsFixed(2);
  }

  void _onAddToCart() {
    if (!_isAvailable) return;

    ref.read(cartProvider.notifier).addItem(
          CartProduct(
            id: widget.productId,
            name: widget.name,
            price: widget.price,
            image: widget.imageUrl,
            unit: _unitCaps,
            quantity: _quantity,
          ),
        );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2A2F2B)
              : const Color(0xFFF1F8E9),
          content: Text(
            '${widget.name} x$_quantity added to cart',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFFE8ECE9)
                  : const Color(0xFF2E6E49),
              fontWeight: FontWeight.w600,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  Widget _buildProductImage() {
    final image = widget.imageUrl.trim();
    if (image.isEmpty) {
      return _ImageFallback(name: widget.name);
    }

    return Image.network(
      image,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF2E7D32),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _ImageFallback(name: widget.name);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final pageBackground = isDarkMode ? const Color(0xFF0F1412) : const Color(0xFF86C893);
    final detailBackground = isDarkMode ? theme.colorScheme.surface : Colors.white;
    final imagePanelBackground = isDarkMode
        ? const Color(0xFF242B28)
        : const Color(0xFFD8E2DA);
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF153E28);
    final descriptionTitleColor = isDarkMode ? Colors.white : const Color(0xFF1E2E23);
    final descriptionColor = isDarkMode ? Colors.white70 : const Color(0xFF5D6E65);
    final backIconColor = isDarkMode ? Colors.white : Colors.black;
    final totalPriceColor = isDarkMode ? Colors.white : Colors.black;
    final ctaBg = isDarkMode ? const Color(0xFF81C784) : Colors.white;
    final ctaFg = isDarkMode ? const Color(0xFF0F1412) : Colors.black;
    final ctaDisabledBg = isDarkMode
        ? const Color(0xFF3A4340)
        : const Color(0xFFE6ECE7);
    final ctaDisabledFg = isDarkMode
        ? Colors.white60
        : const Color(0xFF919E95);

    return Scaffold(
      backgroundColor: pageBackground,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  top: 320,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: detailBackground,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(42),
                        bottomRight: Radius.circular(42),
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 85, 24, 20),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight - 44,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 6),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.name,
                                            style: TextStyle(
                                              fontSize: 34,
                                              fontWeight: FontWeight.w800,
                                              color: titleColor,
                                              height: 1.05,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            _availabilityText,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: _availabilityColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: _QtyStepper(
                                        quantity: _quantity,
                                        canDecrease: _quantity > 1 && _isAvailable,
                                        onDecrease: _decreaseQty,
                                        onIncrease: _increaseQty,
                                        canIncrease: _canIncreaseQty,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    _InfoChip(
                                      text:
                                          'Rs ${_formatPrice(widget.price)}/$_unitLower',
                                      primary: true,
                                    ),
                                    const SizedBox(width: 10),
                                    _InfoChip(
                                      text: '$_quantity $_unitLower',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Product Description',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: descriptionTitleColor,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  widget.description,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: descriptionColor,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 360,
                  decoration: BoxDecoration(
                    color: imagePanelBackground,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(56),
                      bottomRight: Radius.circular(56),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.arrow_back,
                              size: 30,
                              color: backIconColor,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: SizedBox(
                              width: 220,
                              height: 220,
                              child: _buildProductImage(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 10),
            decoration: BoxDecoration(
              color: pageBackground,
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Rs ${_formatPrice(_totalPrice)}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: totalPriceColor,
                        height: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isAvailable ? _onAddToCart : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ctaBg,
                      disabledBackgroundColor: ctaDisabledBg,
                      foregroundColor: ctaFg,
                      disabledForegroundColor: ctaDisabledFg,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      _isAvailable ? 'Add to cart' : 'Out of stock',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final int quantity;
  final bool canDecrease;
  final bool canIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _QtyStepper({
    required this.quantity,
    required this.canDecrease,
    required this.canIncrease,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF242B28) : const Color(0xFFF7FAF8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.white12 : const Color(0xFFE1EAE3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyIconButton(
            icon: Icons.remove,
            onTap: onDecrease,
            enabled: canDecrease,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$quantity',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.white70 : const Color(0xFF86A895),
              ),
            ),
          ),
          _QtyIconButton(
            icon: Icons.add,
            onTap: onIncrease,
            enabled: canIncrease,
          ),
        ],
      ),
    );
  }
}

class _QtyIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _QtyIconButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 24,
        height: 24,
        child: Icon(
          icon,
          size: 17,
          color: enabled
              ? (isDarkMode ? const Color(0xFF9CD3B0) : const Color(0xFF8EB8A0))
              : (isDarkMode ? Colors.white24 : const Color(0xFFC6D6CB)),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String text;
  final bool primary;

  const _InfoChip({
    required this.text,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final chipBg = primary
        ? (isDarkMode ? const Color(0xFF2D3A33) : const Color(0xFFE3F4E8))
        : (isDarkMode ? const Color(0xFF242B28) : const Color(0xFFEDF2EE));
    final chipFg = primary
        ? (isDarkMode ? const Color(0xFF8EE0A7) : const Color(0xFF4C9A61))
        : (isDarkMode ? Colors.white70 : const Color(0xFF56695D));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: chipFg,
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  final String name;

  const _ImageFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDarkMode ? const Color(0xFF242B28) : const Color(0xFFE7EFE9),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 34,
              color: isDarkMode ? Colors.white60 : const Color(0xFF739181),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : const Color(0xFF5E776A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
