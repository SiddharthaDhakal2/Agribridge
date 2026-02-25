import 'dart:async';
import 'dart:convert';

import 'package:agribridge/core/services/storage/user_session_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cartProvider = StateNotifierProvider<CartNotifier, List<CartProduct>>(
  (ref) => CartNotifier(ref.read(userSessionServiceProvider)),
);

class CartNotifier extends StateNotifier<List<CartProduct>> {
  final UserSessionService? _userSessionService;

  CartNotifier(this._userSessionService) : super(const []) {
    loadCartForCurrentUser();
  }

  void loadCartForCurrentUser() {
    final session = _userSessionService;
    if (session == null) {
      state = const [];
      return;
    }

    final userId = session.getCurrentUserId();
    if (userId == null || userId.isEmpty) {
      state = const [];
      return;
    }

    final rawCart = session.getCartForUser(userId);
    if (rawCart == null || rawCart.isEmpty) {
      state = const [];
      return;
    }

    try {
      final decoded = jsonDecode(rawCart);
      if (decoded is! List) {
        state = const [];
        return;
      }

      state = decoded
          .whereType<Map>()
          .map((item) => CartProduct.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      state = const [];
    }
  }

  void clear() {
    state = const [];
  }

  String _itemKey(CartProduct item) {
    final id = item.id.trim();
    if (id.isNotEmpty) return id;
    return '${item.name.trim().toLowerCase()}_${item.unit.trim().toLowerCase()}';
  }

  void addItem(CartProduct newItem) {
    final newItemKey = _itemKey(newItem);
    final existingIndex =
        state.indexWhere((item) => _itemKey(item) == newItemKey);
    if (existingIndex == -1) {
      state = [...state, newItem];
      _persistCurrentUserCart();
      return;
    }

    final existing = state[existingIndex];
    final updatedItem = existing.copyWith(
      quantity: existing.quantity + newItem.quantity,
    );
    final updatedState = [...state];
    updatedState[existingIndex] = updatedItem;
    state = updatedState;
    _persistCurrentUserCart();
  }

  void incrementQuantity(String itemId) {
    final index = state.indexWhere((item) => item.id == itemId);
    if (index == -1) return;

    final updatedState = [...state];
    final item = updatedState[index];
    updatedState[index] = item.copyWith(quantity: item.quantity + 1);
    state = updatedState;
    _persistCurrentUserCart();
  }

  void decrementQuantity(String itemId) {
    final index = state.indexWhere((item) => item.id == itemId);
    if (index == -1) return;

    final updatedState = [...state];
    final item = updatedState[index];
    if (item.quantity <= 1) return;

    updatedState[index] = item.copyWith(quantity: item.quantity - 1);
    state = updatedState;
    _persistCurrentUserCart();
  }

  void removeItem(String itemId) {
    state = state.where((item) => item.id != itemId).toList();
    _persistCurrentUserCart();
  }

  void insertItem(int index, CartProduct item) {
    final updatedState = [...state];
    final insertIndex = index < 0
        ? 0
        : (index > updatedState.length ? updatedState.length : index);
    updatedState.insert(insertIndex, item);
    state = updatedState;
    _persistCurrentUserCart();
  }

  void _persistCurrentUserCart() {
    final session = _userSessionService;
    if (session == null) return;

    final userId = session.getCurrentUserId();
    if (userId == null || userId.isEmpty) return;

    final cartJson = jsonEncode(state.map((item) => item.toJson()).toList());
    unawaited(
      session.saveCartForUser(
        userId: userId,
        cartJson: cartJson,
      ),
    );
  }
}

class CartProduct {
  final String id;
  final String name;
  final double price;
  final String image;
  final String unit;
  final int quantity;

  const CartProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.unit,
    required this.quantity,
  });

  CartProduct copyWith({
    String? id,
    String? name,
    double? price,
    String? image,
    String? unit,
    int? quantity,
  }) {
    return CartProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      image: image ?? this.image,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
      'unit': unit,
      'quantity': quantity,
    };
  }

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      image: json['image']?.toString() ?? '',
      unit: json['unit']?.toString() ?? 'Kg',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }
}
