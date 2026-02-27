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
  final VoidCallback? onStartShopping;

  const OrderScreen({super.key, this.onStartShopping});

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

      final itemSubtotal = items.fold<double>(
        0,
        (sum, item) => sum + item.total,
      );
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final bgColor = isDarkMode ? theme.colorScheme.surface : const Color(0xFFE9ECF2);
    final primaryText = isDarkMode ? Colors.white : _OrderPalette.primaryText;
    final secondaryText = isDarkMode ? Colors.white60 : _OrderPalette.secondaryText;
    final searchIconColor = isDarkMode ? Colors.white70 : const Color(0xFF2E4D83);

    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDarkMode ? Colors.white12 : Colors.transparent,
        ),
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: TextStyle(
          color: primaryText,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(
            color: secondaryText,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: searchIconColor,
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
                  color: secondaryText,
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildStatusFilterRow() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                    : (isDarkMode
                          ? const Color(0xFF242B28)
                          : const Color(0xFFE9ECF2)),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDarkMode ? Colors.white12 : Colors.transparent,
                ),
              ),
              child: Text(
                filter.label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isDarkMode ? Colors.white70 : const Color(0xFF97A3B8)),
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: orderState.when(
          loading: () => Center(
            child: CircularProgressIndicator(
              color: isDarkMode ? const Color(0xFF81C784) : _OrderPalette.totalGreen,
            ),
          ),
          error: (error, _) => _OrderLoadError(
            message: error.toString(),
            onRetry: () =>
                ref.read(orderViewModelProvider.notifier).loadOrders(),
          ),
          data: (orders) {
            final groups = _buildOrderGroups(orders);
            if (groups.isEmpty) {
              return _OrderEmptyState(onStartShopping: widget.onStartShopping);
            }

            final filteredGroups = _applyFilters(groups);

            return RefreshIndicator(
              color: isDarkMode ? const Color(0xFF81C784) : _OrderPalette.totalGreen,
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final statusStyle = _statusStyle(group.status, isDarkMode: isDarkMode);
    final cardColor = isDarkMode ? theme.colorScheme.surface : Colors.white;
    final primaryText = isDarkMode ? Colors.white : _OrderPalette.primaryText;
    final secondaryText = isDarkMode ? Colors.white70 : _OrderPalette.primaryText;
    final dividerColor = isDarkMode ? Colors.white12 : _OrderPalette.divider;
    final totalColor = isDarkMode ? const Color(0xFF8EE0A7) : _OrderPalette.totalGreen;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.white12 : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.24 : 0.06),
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
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatDate(group.createdAt),
                      style: TextStyle(
                        color: secondaryText,
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
                  border: Border.all(color: statusStyle.border),
                ),
                child: Text(
                  statusStyle.label,
                  style: TextStyle(
                    color: statusStyle.foreground,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: dividerColor),
          const SizedBox(height: 8),
          ...group.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.name} x ${item.quantity}',
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    'Rs ${formatAmount(item.total)}',
                    style: TextStyle(
                      color: primaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(color: dividerColor),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery to',
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      group.customerName.isEmpty ? 'N/A' : group.customerName,
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      group.deliveryAddress.isEmpty
                          ? 'N/A'
                          : group.deliveryAddress,
                      style: TextStyle(
                        color: secondaryText,
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
                  Text(
                    'Total Amount',
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rs ${formatAmount(group.totalWithDelivery)}',
                    style: TextStyle(
                      color: totalColor,
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

  _StatusStyle _statusStyle(String status, {required bool isDarkMode}) {
    if (isDarkMode) {
      switch (status) {
        case 'processing':
          return const _StatusStyle(
            label: 'Processing',
            background: Color(0xFF123661),
            foreground: Color(0xFF9FC4FF),
            border: Color(0xFF2E5A95),
          );
        case 'pending':
          return const _StatusStyle(
            label: 'Pending',
            background: Color(0xFF5A3A00),
            foreground: Color(0xFFFFD58A),
            border: Color(0xFF8F5A00),
          );
        case 'shipped':
          return const _StatusStyle(
            label: 'Shipped',
            background: Color(0xFF3A2D62),
            foreground: Color(0xFFC3B4FF),
            border: Color(0xFF5D4A91),
          );
        case 'delivered':
          return const _StatusStyle(
            label: 'Delivered',
            background: Color(0xFF154B2E),
            foreground: Color(0xFF8EE0A7),
            border: Color(0xFF2A7348),
          );
        case 'cancelled':
          return const _StatusStyle(
            label: 'Cancelled',
            background: Color(0xFF5A2020),
            foreground: Color(0xFFFFB4AB),
            border: Color(0xFF8B3A3A),
          );
        default:
          return const _StatusStyle(
            label: 'Pending',
            background: Color(0xFF5A3A00),
            foreground: Color(0xFFFFD58A),
            border: Color(0xFF8F5A00),
          );
      }
    }

    switch (status) {
      case 'processing':
        return const _StatusStyle(
          label: 'Processing',
          background: Color(0xFFD7E6FF),
          foreground: Color(0xFF1348B5),
          border: Color(0xFFAFC8F1),
        );
      case 'pending':
        return const _StatusStyle(
          label: 'Pending',
          background: Color(0xFFFFE8C9),
          foreground: Color(0xFFB26E00),
          border: Color(0xFFF3D3A4),
        );
      case 'shipped':
        return const _StatusStyle(
          label: 'Shipped',
          background: Color(0xFFE7E1FF),
          foreground: Color(0xFF6443C5),
          border: Color(0xFFD3C8FF),
        );
      case 'delivered':
        return const _StatusStyle(
          label: 'Delivered',
          background: Color(0xFFD9F3E2),
          foreground: Color(0xFF177E41),
          border: Color(0xFFBEE8CE),
        );
      case 'cancelled':
        return const _StatusStyle(
          label: 'Cancelled',
          background: Color(0xFFFADDDD),
          foreground: Color(0xFFB42318),
          border: Color(0xFFF0C1BF),
        );
      default:
        return const _StatusStyle(
          label: 'Pending',
          background: Color(0xFFFFE8C9),
          foreground: Color(0xFFB26E00),
          border: Color(0xFFF3D3A4),
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
  final Color border;

  const _StatusStyle({
    required this.label,
    required this.background,
    required this.foreground,
    required this.border,
  });
}

class _OrderFilterOption {
  final String value;
  final String label;

  const _OrderFilterOption({required this.value, required this.label});
}

class _OrderEmptyState extends StatelessWidget {
  final VoidCallback? onStartShopping;

  const _OrderEmptyState({this.onStartShopping});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF111827);
    final subtitleColor = isDarkMode ? Colors.white70 : const Color(0xFF4B5563);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF262D2A) : const Color(0xFFEDEFF2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDarkMode ? 0.24 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 42,
                color: isDarkMode ? Colors.white60 : const Color(0xFF9FA6B2),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'No orders yet',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Start shopping to place your first order.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: subtitleColor,
                fontSize: 20,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onStartShopping ?? () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode
                    ? const Color(0xFF81C784)
                    : const Color(0xFF10B34A),
                foregroundColor: isDarkMode ? const Color(0xFF0F1412) : Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 12,
                ),
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
      ),
    );
  }
}

class _OrderFilterEmptyState extends StatelessWidget {
  const _OrderFilterEmptyState();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Text(
        'No orders match this filter',
        style: TextStyle(
          color: isDarkMode ? Colors.white70 : _OrderPalette.secondaryText,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Failed to load orders',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.white : _OrderPalette.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : _OrderPalette.secondaryText,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode
                    ? const Color(0xFF81C784)
                    : _OrderPalette.totalGreen,
                foregroundColor: isDarkMode
                    ? const Color(0xFF0F1412)
                    : Colors.white,
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
