import 'package:agribridge/features/dashboard/domain/entities/order_entity.dart';
import 'package:agribridge/features/dashboard/presentation/state/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const List<_OrderFilterOption> _orderFilterOptions = [
  _OrderFilterOption(value: 'all', label: 'All Orders'),
  _OrderFilterOption(value: 'pending', label: 'Pending'),
  _OrderFilterOption(value: 'processing', label: 'Processing'),
  _OrderFilterOption(value: 'shipped', label: 'Shipped'),
  _OrderFilterOption(value: 'delivered', label: 'Delivered'),
  _OrderFilterOption(value: 'cancelled', label: 'Cancelled'),
];

class OrderScreen extends ConsumerStatefulWidget {
  const OrderScreen({super.key});

  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = _orderFilterOptions.first.value;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ref.read(orderViewModelProvider.notifier).loadOrders();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final local = date.toLocal();
    return '${months[local.month - 1]} ${local.day}, ${local.year}';
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(2);
  }

  String _displayOrderId(String orderId) {
    final trimmed = orderId.trim();
    if (trimmed.isEmpty) return 'N/A';
    if (trimmed.length >= 6) {
      return 'OA${trimmed.substring(trimmed.length - 6).toUpperCase()}';
    }
    return trimmed.toUpperCase();
  }

  String _normalizeStatus(String value) {
    const validStatuses = {
      'pending',
      'processing',
      'shipped',
      'delivered',
      'cancelled',
    };
    final normalized = value.trim().toLowerCase();
    return validStatuses.contains(normalized) ? normalized : 'pending';
  }

  List<_OrderGroup> _buildOrderGroups(List<OrderEntity> orders) {
    final groupedMap = <String, List<OrderEntity>>{};

    for (final item in orders) {
      final key = item.orderId.trim().isEmpty
          ? '${item.productId}_${item.createdAt?.millisecondsSinceEpoch ?? 0}'
          : item.orderId;
      groupedMap.putIfAbsent(key, () => []).add(item);
    }

    final groups = groupedMap.entries.map((entry) {
      final items = entry.value;
      final first = items.first;
      final status = _normalizeStatus(first.status);
      final createdAt = first.createdAt;

      final itemSubtotal = items.fold<double>(0, (sum, item) => sum + item.total);
      double subtotal = itemSubtotal > 0 ? itemSubtotal : first.orderSubtotal;

      double deliveryFee = first.deliveryFee;
      if (deliveryFee <= 0) {
        final inferredDeliveryFee = first.orderSubtotal - subtotal;
        if (inferredDeliveryFee > 0) {
          deliveryFee = inferredDeliveryFee;
        } else if (subtotal > 0) {
          deliveryFee = 120;
        }
      }

      String customerName = first.customerName.trim();
      String deliveryAddress = first.deliveryAddress.trim();
      for (final item in items) {
        if (customerName.isEmpty && item.customerName.trim().isNotEmpty) {
          customerName = item.customerName.trim();
        }
        if (deliveryAddress.isEmpty && item.deliveryAddress.trim().isNotEmpty) {
          deliveryAddress = item.deliveryAddress.trim();
        }
      }

      return _OrderGroup(
        orderId: entry.key,
        status: status,
        createdAt: createdAt,
        customerName: customerName,
        deliveryAddress: deliveryAddress,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        items: items
            .map(
              (item) => _OrderLineItem(
                name: item.productName,
                quantity: item.quantity,
                total: item.total,
              ),
            )
            .toList(),
      );
    }).toList();

    groups.sort((a, b) {
      final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

    return groups;
  }

  List<_OrderGroup> _applyFilters(List<_OrderGroup> groups) {
    final query = _searchQuery.trim().toLowerCase();

    return groups.where((group) {
      final statusMatches =
          _selectedStatus == 'all' || group.status == _selectedStatus;
      if (!statusMatches) return false;
      if (query.isEmpty) return true;

      final searchTargets = <String>[
        group.orderId.toLowerCase(),
        _displayOrderId(group.orderId).toLowerCase(),
        group.customerName.toLowerCase(),
        group.deliveryAddress.toLowerCase(),
        ...group.items.map((item) => item.name.toLowerCase()),
      ];

      return searchTargets.any((target) => target.contains(query));
    }).toList();
  }

  Widget _buildSearchField() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECF2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: const TextStyle(
          color: _OrderPalette.primaryText,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: const TextStyle(
            color: _OrderPalette.secondaryText,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF2E4D83),
            size: 20,
          ),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: _OrderPalette.secondaryText,
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildStatusFilterRow() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _orderFilterOptions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = _orderFilterOptions[index];
          final isSelected = filter.value == _selectedStatus;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedStatus = filter.value;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF21C371)
                    : const Color(0xFFE9ECF2),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                filter.label,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF97A3B8),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      body: SafeArea(
        child: orderState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: _OrderPalette.totalGreen),
          ),
          error: (error, _) => _OrderLoadError(
            message: error.toString(),
            onRetry: () =>
                ref.read(orderViewModelProvider.notifier).loadOrders(),
          ),
          data: (orders) {
            final groups = _buildOrderGroups(orders);
            if (groups.isEmpty) {
              return const Center(
                child: Text(
                  'No orders found',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _OrderPalette.secondaryText,
                  ),
                ),
              );
            }

            final filteredGroups = _applyFilters(groups);

            return RefreshIndicator(
              color: _OrderPalette.totalGreen,
              onRefresh: () =>
                  ref.read(orderViewModelProvider.notifier).refreshOrders(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 16),
                children: [
                  _buildSearchField(),
                  const SizedBox(height: 14),
                  _buildStatusFilterRow(),
                  const SizedBox(height: 14),
                  if (filteredGroups.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 28),
                      child: _OrderFilterEmptyState(),
                    )
                  else
                    ...filteredGroups.map(
                      (group) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _OrderCard(
                          group: group,
                          formatAmount: _formatAmount,
                          formatDate: _formatDate,
                          formatOrderId: _displayOrderId,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final _OrderGroup group;
  final String Function(double value) formatAmount;
  final String Function(DateTime? value) formatDate;
  final String Function(String value) formatOrderId;

  const _OrderCard({
    required this.group,
    required this.formatAmount,
    required this.formatDate,
    required this.formatOrderId,
  });

  @override
  Widget build(BuildContext context) {
    final statusStyle = _statusStyle(group.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order ID: ${formatOrderId(group.orderId)}',
                      style: const TextStyle(
                        color: _OrderPalette.primaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatDate(group.createdAt),
                      style: const TextStyle(
                        color: _OrderPalette.primaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: statusStyle.background,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  statusStyle.label,
                  style: TextStyle(
                    color: statusStyle.foreground,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: _OrderPalette.divider),
          const SizedBox(height: 8),
          ...group.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.name} x ${item.quantity}',
                      style: const TextStyle(
                        color: _OrderPalette.primaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    'Rs ${formatAmount(item.total)}',
                    style: const TextStyle(
                      color: _OrderPalette.primaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(color: _OrderPalette.divider),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delivery to',
                      style: TextStyle(
                        color: _OrderPalette.primaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      group.customerName.isEmpty ? 'N/A' : group.customerName,
                      style: const TextStyle(
                        color: _OrderPalette.primaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      group.deliveryAddress.isEmpty
                          ? 'N/A'
                          : group.deliveryAddress,
                      style: const TextStyle(
                        color: _OrderPalette.primaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(
                      color: _OrderPalette.primaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rs ${formatAmount(group.totalWithDelivery)}',
                    style: const TextStyle(
                      color: _OrderPalette.totalGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  _StatusStyle _statusStyle(String status) {
    switch (status) {
      case 'processing':
        return const _StatusStyle(
          label: 'Processing',
          background: Color(0xFFD7E6FF),
          foreground: Color(0xFF1348B5),
        );
      case 'pending':
        return const _StatusStyle(
          label: 'Pending',
          background: Color(0xFFFFE8C9),
          foreground: Color(0xFFB26E00),
        );
      case 'shipped':
        return const _StatusStyle(
          label: 'Shipped',
          background: Color(0xFFE7E1FF),
          foreground: Color(0xFF6443C5),
        );
      case 'delivered':
        return const _StatusStyle(
          label: 'Delivered',
          background: Color(0xFFD9F3E2),
          foreground: Color(0xFF177E41),
        );
      case 'cancelled':
        return const _StatusStyle(
          label: 'Cancelled',
          background: Color(0xFFFADDDD),
          foreground: Color(0xFFB42318),
        );
      default:
        return const _StatusStyle(
          label: 'Pending',
          background: Color(0xFFFFE8C9),
          foreground: Color(0xFFB26E00),
        );
    }
  }
}

class _OrderGroup {
  final String orderId;
  final String status;
  final DateTime? createdAt;
  final String customerName;
  final String deliveryAddress;
  final double subtotal;
  final double deliveryFee;
  final List<_OrderLineItem> items;

  const _OrderGroup({
    required this.orderId,
    required this.status,
    required this.createdAt,
    required this.customerName,
    required this.deliveryAddress,
    required this.subtotal,
    required this.deliveryFee,
    required this.items,
  });

  double get totalWithDelivery => subtotal + deliveryFee;
}

class _OrderLineItem {
  final String name;
  final int quantity;
  final double total;

  const _OrderLineItem({
    required this.name,
    required this.quantity,
    required this.total,
  });
}

class _StatusStyle {
  final String label;
  final Color background;
  final Color foreground;

  const _StatusStyle({
    required this.label,
    required this.background,
    required this.foreground,
  });
}

class _OrderFilterOption {
  final String value;
  final String label;

  const _OrderFilterOption({required this.value, required this.label});
}

class _OrderFilterEmptyState extends StatelessWidget {
  const _OrderFilterEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No orders match this filter',
        style: TextStyle(
          color: _OrderPalette.secondaryText,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _OrderLoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _OrderLoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Failed to load orders',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _OrderPalette.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _OrderPalette.secondaryText),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _OrderPalette.totalGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderPalette {
  static const Color primaryText = Color(0xFF1B3558);
  static const Color secondaryText = Color(0xFF6D7787);
  static const Color divider = Color(0xFFD6DCE5);
  static const Color totalGreen = Color(0xFF009F3B);
}
