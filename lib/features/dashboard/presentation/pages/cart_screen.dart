import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  final VoidCallback? onStartShopping;

  const CartScreen({super.key, this.onStartShopping});

  @override
  Widget build(BuildContext context) {
    return CartScreenBody(onStartShopping: onStartShopping);
  }
}

class CartScreenBody extends StatefulWidget {
  final VoidCallback? onStartShopping;

  const CartScreenBody({super.key, this.onStartShopping});

  @override
  State<CartScreenBody> createState() => _CartScreenBodyState();
}

class _CartScreenBodyState extends State<CartScreenBody> {
  final List<CartProduct> cartItems = [
    CartProduct(
      name: 'Lemon',
      price: 50,
      image: 'assets/images/lemon.jpg',
      quantity: 1,
    ),
    CartProduct(
      name: 'Wheat',
      price: 70,
      image: 'assets/images/wheat.jpg',
      quantity: 1,
    ),
    CartProduct(
      name: 'Apple',
      price: 250,
      image: 'assets/images/apple.jpg',
      quantity: 1,
    ),
  ];

  int get subtotal => cartItems.fold(
        0,
        (sum, item) => sum + item.price * item.quantity,
      );

  final int deliveryCharge = 120;
  int get activeDeliveryCharge => cartItems.isEmpty ? 0 : deliveryCharge;
  int get total => subtotal + activeDeliveryCharge;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              CartPalette.pageTop,
              CartPalette.pageBottom,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: cartItems.isEmpty ? _buildEmptyState() : _buildCartList(),
              ),
              if (cartItems.isNotEmpty) _buildSummaryCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        final item = cartItems[index];
        return Dismissible(
          key: ValueKey('${item.name}_$index'),
          direction: DismissDirection.endToStart,
          onDismissed: (_) {
            final removedItem = item;
            setState(() {
              cartItems.removeAt(index);
            });

            final messenger = ScaffoldMessenger.of(context);
            messenger.hideCurrentSnackBar();
            final snackBarController = messenger.showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
                content: Text('${removedItem.name} removed from cart'),
                action: SnackBarAction(
                  label: 'Undo',
                  textColor: Colors.white,
                  onPressed: () {
                    setState(() {
                      final insertIndex = index <= cartItems.length ? index : cartItems.length;
                      cartItems.insert(insertIndex, removedItem);
                    });
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
            onAdd: () {
              setState(() {
                item.quantity++;
              });
            },
            onRemove: () {
              setState(() {
                if (item.quantity > 1) {
                  item.quantity--;
                }
              });
            },
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
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
              value: 'Rs $subtotal',
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Delivery Charge',
              value: 'Rs $activeDeliveryCharge',
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(
                color: CartPalette.softBorder,
                height: 1,
              ),
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
                    'Rs $total',
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
                onPressed: isEmpty ? null : () {},
                child: const Text(
                  'Proceed To Checkout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartProduct {
  final String name;
  final int price;
  final String image;
  int quantity;

  CartProduct({
    required this.name,
    required this.price,
    required this.image,
    required this.quantity,
  });
}

class CartItemCard extends StatelessWidget {
  final CartProduct item;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final int itemTotal = item.price * item.quantity;

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
            child: SizedBox(
              width: 76,
              height: 76,
              child: Image.asset(
                item.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: CartPalette.softGreen,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: CartPalette.darkGreen,
                    ),
                  );
                },
              ),
            ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: CartPalette.softGreen,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Rs ${item.price}/Kg',
                    style: const TextStyle(
                      color: CartPalette.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Total: Rs $itemTotal',
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
                _QuantityActionButton(
                  icon: Icons.remove,
                  onTap: onRemove,
                ),
                Container(
                  width: 34,
                  alignment: Alignment.center,
                  child: Text(
                    '${item.quantity}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: CartPalette.darkGreen,
                    ),
                  ),
                ),
                _QuantityActionButton(
                  icon: Icons.add,
                  onTap: onAdd,
                ),
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

  const _QuantityActionButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 18,
          color: CartPalette.primaryGreen,
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({
    required this.label,
    required this.value,
  });

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
