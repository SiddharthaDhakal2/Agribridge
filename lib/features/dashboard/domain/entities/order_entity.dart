class OrderEntity {
  final String userId;
  final String orderId;
  final String productId;
  final String productName;
  final String customerName;
  final String deliveryAddress;
  final String imagePath;
  final double pricePerUnit;
  final int quantity;
  final double total;
  final double orderSubtotal;
  final double deliveryFee;
  final String status;
  final String unit;
  final DateTime? createdAt;

  OrderEntity({
    required this.userId,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.customerName,
    required this.deliveryAddress,
    required this.imagePath,
    required this.pricePerUnit,
    required this.quantity,
    required this.total,
    required this.orderSubtotal,
    required this.deliveryFee,
    required this.status,
    required this.unit,
    required this.createdAt,
  });

  double get orderTotalWithDelivery => orderSubtotal + deliveryFee;
}
