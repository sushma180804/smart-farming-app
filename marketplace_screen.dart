// lib/screens/marketplace_screen.dart (REPLACE ENTIRE FILE)

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:smart_farming_app/screens/my_products_screen.dart'; // <-- Import new screen
import 'package:smart_farming_app/screens/sell_product_screen.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('available_products'.tr()),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        // ======== NEW ACTION BUTTON ========
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyProductsScreen()));
            },
            icon: const Icon(Icons.storefront),
            label: Text('my_products'.tr()),
          )
        ],
        // ===================================
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').orderBy('postedAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          // ... (Rest of the body code is the same and correct) ...
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No products available for sale yet.'));
          }

          final products = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(10.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 0.75,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final productData = products[index].data() as Map<String, dynamic>;
              final String name = productData['name'] ?? 'N/A';
              final String price = productData['price'] ?? 'N/A';
              final String imageUrl = productData['imageUrl'] ?? '';
              
              return Card(
                clipBehavior: Clip.antiAlias,
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.broken_image, size: 40, color: Colors.grey);
                              },
                            )
                          : const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(price, style: TextStyle(color: Colors.green.shade800, fontSize: 14)),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const SellProductScreen(),
          ));
        },
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        tooltip: 'sell_new_product'.tr(),
        child: const Icon(Icons.add_shopping_cart),
      ),
    );
  }
}