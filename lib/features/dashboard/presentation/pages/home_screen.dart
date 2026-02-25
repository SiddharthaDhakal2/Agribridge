
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/home_provider.dart';
import 'product_detail_screen.dart';

final selectedCategoryProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const greenColor = Color(0xFF0F6E2D);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(homeProvider);
    final categories = ['All', 'Fruits', 'Grains', 'Vegetables'];
    final selectedIndex = ref.watch(selectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenColor,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(color: greenColor),
          Column(
            children: [
              const SizedBox(height: 70),
              Container(
                color: Colors.grey.shade100,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF3B4A63),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return ChoiceChip(
                            label: Text(categories[index]),
                            selected: selectedIndex == index,
                            onSelected: (selected) {
                              if (selected) {
                                ref.read(selectedCategoryProvider.notifier).state = index;
                              }
                            },
                            selectedColor: greenColor,
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: selectedIndex == index ? Colors.white : greenColor,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      height: 2,
                      color: Colors.grey.shade300,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.grey.shade100,
                  padding: const EdgeInsets.all(16),
                  child: productsAsync.when(
                    data: (products) {
                      if (products.isEmpty) {
                        return const Center(child: Text('No products available'));
                      }
                      final latestFirst = products.reversed.toList();
                      final filtered = selectedIndex == 0
                          ? latestFirst
                          : latestFirst.where((p) {
                              final cat = categories[selectedIndex].toLowerCase();
                              return p.category.toLowerCase() == cat;
                            }).toList();
                      if (filtered.isEmpty) {
                        return const Center(child: Text('No products in this category'));
                      }
                      return GridView.builder(
                        itemCount: filtered.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.95,
                        ),
                        itemBuilder: (context, index) {
                          final product = filtered[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  child: product.image.isNotEmpty
                                      ? Image.network(
                                          product.image.startsWith('http')
                                              ? product.image
                                              : 'http://10.0.2.2:5000${product.image}',
                                          height: 130,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          height: 130,
                                          width: double.infinity,
                                          color: Colors.grey.shade200,
                                          child: const Center(child: Icon(Icons.image, size: 40)),
                                        ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              product.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Rs ${product.price}/Kg',
                                              style: const TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: greenColor,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.add, color: Colors.white, size: 20),
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => ProductDetailScreen(
                                                  productId: product.id,
                                                  imageUrl: product.image.startsWith('http')
                                                      ? product.image
                                                      : 'http://10.0.2.2:5000${product.image}',
                                                  name: product.name,
                                                  description: product.description,
                                                  price: product.price,
                                                  unit: product.unit,
                                                  availability: product.availability,
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
                              ],
                            ),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: Icon(Icons.search, color: greenColor),
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
