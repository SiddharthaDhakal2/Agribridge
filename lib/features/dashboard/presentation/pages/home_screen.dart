import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agribridge/core/api/api_endpoint.dart';

import '../state/home_provider.dart';
import 'product_detail_screen.dart';

final selectedCategoryProvider = StateProvider<int>((ref) => 0);
final searchQueryProvider = StateProvider<String>((ref) => '');

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const greenColor = Color(0xFF0F6E2D);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(homeProvider);
    final categories = ['All', 'Fruits', 'Grains', 'Vegetables'];
    final selectedIndex = ref.watch(selectedCategoryProvider);
    final searchQuery = ref.watch(searchQueryProvider).trim().toLowerCase();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    final topBackground = isDarkMode ? const Color(0xFF163224) : greenColor;
    final contentBackground = isDarkMode
        ? const Color(0xFF101512)
        : Colors.grey.shade100;
    final cardBackground = isDarkMode ? colorScheme.surface : Colors.white;
    final mutedDividerColor = isDarkMode ? Colors.white12 : Colors.grey.shade300;
    final sectionTitleColor = isDarkMode
        ? colorScheme.onSurface
        : const Color(0xFF3B4A63);
    final itemTitleColor = isDarkMode
        ? colorScheme.onSurface
        : const Color(0xFF1F2937);
    final priceColor = isDarkMode ? const Color(0xFF8EE0A7) : Colors.green;
    final cardShadow = isDarkMode
        ? Colors.black.withValues(alpha: 0.32)
        : Colors.black.withValues(alpha: 0.05);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: topBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0,
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
      ),
      body: Stack(
        children: [
          Container(color: topBackground),
          Column(
            children: [
              const SizedBox(height: 70),
              Container(
                color: contentBackground,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: sectionTitleColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final isSelected = selectedIndex == index;
                          return ChoiceChip(
                            label: Text(categories[index]),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                ref.read(selectedCategoryProvider.notifier).state =
                                    index;
                              }
                            },
                            selectedColor: isDarkMode
                                ? const Color(0xFF1F7A3A)
                                : greenColor,
                            backgroundColor: cardBackground,
                            side: BorderSide(
                              color: isDarkMode ? Colors.white12 : Colors.transparent,
                            ),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isDarkMode ? Colors.white70 : greenColor),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(height: 2, color: mutedDividerColor),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: contentBackground,
                  padding: const EdgeInsets.all(16),
                  child: productsAsync.when(
                    data: (products) {
                      if (products.isEmpty) {
                        return const Center(child: Text('No products available'));
                      }
                      final screenWidth = MediaQuery.of(context).size.width;
                      final isCompactCardLayout = screenWidth <= 430;
                      final gridChildAspectRatio =
                          isCompactCardLayout ? 0.76 : 0.86;
                      final cardContentPadding = isCompactCardLayout ? 6.0 : 8.0;
                      final productNameFontSize = isCompactCardLayout ? 14.0 : 15.0;
                      final productPriceFontSize = isCompactCardLayout ? 15.0 : 16.0;
                      final addButtonSize = isCompactCardLayout ? 30.0 : 32.0;
                      final productNameMaxLines = isCompactCardLayout ? 1 : 2;
                      final latestFirst = products.reversed.toList();
                      final categoryFiltered = selectedIndex == 0
                          ? latestFirst
                          : latestFirst.where((p) {
                              final cat = categories[selectedIndex].toLowerCase();
                              return p.category.toLowerCase() == cat;
                            }).toList();
                      final filtered = searchQuery.isEmpty
                          ? categoryFiltered
                          : categoryFiltered.where((p) {
                              return p.name.toLowerCase().contains(searchQuery) ||
                                  p.category.toLowerCase().contains(searchQuery) ||
                                  p.description.toLowerCase().contains(searchQuery);
                            }).toList();
                      if (filtered.isEmpty) {
                        return const Center(
                          child: Text('No products found'),
                        );
                      }
                      return GridView.builder(
                        itemCount: filtered.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: gridChildAspectRatio,
                        ),
                        itemBuilder: (context, index) {
                          final product = filtered[index];
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final cardImageHeight =
                                  constraints.maxHeight *
                                  (isCompactCardLayout ? 0.56 : 0.60);

                              return Container(
                                decoration: BoxDecoration(
                                  color: cardBackground,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDarkMode
                                        ? Colors.white10
                                        : Colors.black.withValues(alpha: 0.04),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: cardShadow,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      child: product.image.isNotEmpty
                                          ? Image.network(
                                              ApiEndpoints.resolveMediaUrl(
                                                product.image,
                                              ),
                                              height: cardImageHeight,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            )
                                          : Container(
                                              height: cardImageHeight,
                                              width: double.infinity,
                                              color: isDarkMode
                                                  ? Colors.white10
                                                  : Colors.grey.shade200,
                                              child: Icon(
                                                Icons.image,
                                                size: 40,
                                                color: isDarkMode
                                                    ? Colors.white54
                                                    : Colors.black45,
                                              ),
                                            ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                          cardContentPadding,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    product.name,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          productNameFontSize,
                                                      color: itemTitleColor,
                                                    ),
                                                    maxLines:
                                                        productNameMaxLines,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(
                                                    height: isCompactCardLayout
                                                        ? 2
                                                        : 4,
                                                  ),
                                                  Text(
                                                    'Rs ${product.price}/Kg',
                                                    style: TextStyle(
                                                      color: priceColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize:
                                                          productPriceFontSize,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(
                                                right: 8,
                                              ),
                                              width: addButtonSize,
                                              height: addButtonSize,
                                              decoration: BoxDecoration(
                                                color: isDarkMode
                                                    ? const Color(0xFF2F8F4B)
                                                    : greenColor,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.add,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (_) => ProductDetailScreen(
                                                        productId: product.id,
                                                        imageUrl:
                                                            ApiEndpoints.resolveMediaUrl(
                                                              product.image,
                                                            ),
                                                        name: product.name,
                                                        description:
                                                            product.description,
                                                        price: product.price,
                                                        unit: product.unit,
                                                        stockQuantity:
                                                            product.quantity,
                                                        availability:
                                                            product.availability,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                padding: EdgeInsets.zero,
                                                splashRadius: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Center(child: Text('Error: $e')),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 16,
            right: 16,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: isDarkMode ? colorScheme.surface : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode ? Colors.white12 : Colors.transparent,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDarkMode ? 0.24 : 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                style: TextStyle(color: colorScheme.onSurface),
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                },
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.white60 : Colors.black54,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDarkMode ? Colors.white70 : greenColor,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
