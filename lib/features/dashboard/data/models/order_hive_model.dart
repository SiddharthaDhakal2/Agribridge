import 'package:hive/hive.dart';

import '../../domain/entities/order_entity.dart';

part 'order_hive_model.g.dart';

@HiveType(typeId: 7)
class OrderHiveModel extends HiveObject {
  static const double defaultDeliveryFee = 120;

  @HiveField(10)
  final String? userId;
  @HiveField(0)
  final String orderId;
  @HiveField(1)
  final String productId;
  @HiveField(2)
  final String productName;
  @HiveField(13)
  final String customerName;
  @HiveField(14)
  final String deliveryAddress;
  @HiveField(3)
  final String imagePath;
  @HiveField(4)
  final double pricePerUnit;
  @HiveField(5)
  final int quantity;
  @HiveField(6)
  final double total;
  @HiveField(11)
  final double? orderSubtotal;
  @HiveField(12)
  final double? deliveryFee;
  @HiveField(7)
  final String status;
  @HiveField(8)
  final String unit;
  @HiveField(9)
  final DateTime? createdAt;

  OrderHiveModel({
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

  factory OrderHiveModel.fromJson(Map<String, dynamic> json) {
    final price = _doubleValue(json['pricePerUnit']);
    final quantity = _intValue(json['quantity']);
    final parsedTotal = _doubleValue(json['total']);
    final parsedOrderSubtotal = _doubleValue(json['orderSubtotal']);
    final parsedDeliveryFee = _doubleValue(json['deliveryFee']);
    final resolvedOrderSubtotal = parsedOrderSubtotal > 0
        ? parsedOrderSubtotal
        : parsedTotal;
    final resolvedDeliveryFee = parsedDeliveryFee > 0
        ? parsedDeliveryFee
        : (resolvedOrderSubtotal > 0 ? defaultDeliveryFee : 0.0);
    final normalizedStatus = _normalizeStatus(_stringValue(json['status']));
    final parsedUnit = _stringValue(json['unit']);

    return OrderHiveModel(
      userId: _stringValue(json['userId']),
      orderId: _stringValue(json['orderId']),
      productId: _stringValue(json['productId']),
      productName: _stringValue(json['productName']),
      customerName: _stringValue(json['customerName']),
      deliveryAddress: _stringValue(json['deliveryAddress']),
      imagePath: _stringValue(json['imagePath']),
      pricePerUnit: price,
      quantity: quantity,
      total: parsedTotal > 0 ? parsedTotal : price * quantity,
      orderSubtotal: resolvedOrderSubtotal,
      deliveryFee: resolvedDeliveryFee,
      status: normalizedStatus,
      unit: parsedUnit.isEmpty ? 'Kg' : parsedUnit,
      createdAt: _dateValue(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId ?? '',
      'orderId': orderId,
      'productId': productId,
      'productName': productName,
      'customerName': customerName,
      'deliveryAddress': deliveryAddress,
      'imagePath': imagePath,
      'pricePerUnit': pricePerUnit,
      'quantity': quantity,
      'total': total,
      'orderSubtotal': orderSubtotal ?? 0,
      'deliveryFee': deliveryFee ?? 0,
      'status': status,
      'unit': unit,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  OrderEntity toEntity() {
    return OrderEntity(
      userId: userId?.trim().isNotEmpty == true ? userId! : '',
      orderId: orderId,
      productId: productId,
      productName: productName,
      customerName: customerName,
      deliveryAddress: deliveryAddress,
      imagePath: imagePath,
      pricePerUnit: pricePerUnit,
      quantity: quantity,
      total: total,
      orderSubtotal: orderSubtotal ?? 0,
      deliveryFee: deliveryFee ?? 0,
      status: status,
      unit: unit,
      createdAt: createdAt,
    );
  }

  static List<OrderHiveModel> fromOrderResponse(dynamic rawOrders) {
    if (rawOrders is! List) return [];

    final models = <OrderHiveModel>[];

    for (final rawOrder in rawOrders) {
      if (rawOrder is! Map) continue;
      final order = Map<String, dynamic>.from(rawOrder);
      final userRefRaw = order['userId'];
      String orderUserId = '';
      if (userRefRaw is Map) {
        orderUserId = _stringValue(userRefRaw['_id']);
      } else {
        orderUserId = _stringValue(userRefRaw);
      }
      final orderId = _stringValue(order['_id']);
      final normalizedStatus = _normalizeStatus(_stringValue(order['status']));
      final createdAt = _dateValue(order['createdAt']);
      final customerName = _stringValue(order['customerName']);
      final deliveryAddress = _stringValue(order['address']);
      final parsedOrderSubtotal = _doubleValue(order['total']);
      final parsedDeliveryFee = _doubleValue(order['deliveryFee']);
      final effectiveDeliveryFee = parsedDeliveryFee > 0
          ? parsedDeliveryFee
          : (parsedOrderSubtotal > 0 ? defaultDeliveryFee : 0.0);

      final items = order['items'];
      if (items is! List || items.isEmpty) continue;

      for (final rawItem in items) {
        if (rawItem is! Map) continue;
        final item = Map<String, dynamic>.from(rawItem);

        final productRefRaw = item['productId'];
        Map<String, dynamic>? productRef;
        String productId = '';

        if (productRefRaw is Map) {
          productRef = Map<String, dynamic>.from(productRefRaw);
          productId = _stringValue(productRef['_id']);
        } else {
          productId = _stringValue(productRefRaw);
        }

        final itemName = _stringValue(item['name']);
        final productName = itemName.isNotEmpty
            ? itemName
            : _stringValue(productRef?['name']);
        final imagePath = _stringValue(productRef?['image']);
        final parsedUnit = _stringValue(productRef?['unit']);
        final price = _doubleValue(item['price']);
        final quantity = _intValue(item['quantity']);
        final parsedTotal = _doubleValue(item['total']);
        final total = parsedTotal > 0 ? parsedTotal : price * quantity;

        models.add(
          OrderHiveModel(
            userId: orderUserId,
            orderId: orderId,
            productId: productId,
            productName: productName.isEmpty ? 'Product' : productName,
            customerName: customerName,
            deliveryAddress: deliveryAddress,
            imagePath: imagePath,
            pricePerUnit: price,
            quantity: quantity,
            total: total,
            orderSubtotal: parsedOrderSubtotal,
            deliveryFee: effectiveDeliveryFee,
            status: normalizedStatus,
            unit: parsedUnit.isEmpty ? 'Kg' : parsedUnit,
            createdAt: createdAt,
          ),
        );
      }
    }

    return models;
  }

  static String _normalizeStatus(String value) {
    const validStatuses = {
      'pending',
      'processing',
      'shipped',
      'delivered',
      'cancelled',
    };

    final normalized = value.toLowerCase();
    if (validStatuses.contains(normalized)) return normalized;
    return 'pending';
  }

  static String _stringValue(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static double _doubleValue(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static int _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime? _dateValue(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
