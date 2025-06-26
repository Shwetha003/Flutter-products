import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          IconButton(
            onPressed: () {
              context.push('/support');
            },
            icon: Icon(Icons.support_agent),
          ),
        ],
      ),
      body: cart.items.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : ListView(
              children: cart.items.entries.map((entry) {
                final product = _productById(entry.key.id);
                final qty = entry.value;
                return ListTile(
                  title: Text(product?.name ?? 'Unknown'),
                  subtitle: Text('Quantity: $qty'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      if (product != null) cart.removeItem(product);
                    },
                  ),
                );
              }).toList(),
            ),
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : Padding(
              padding: EdgeInsets.all(8.w),
              child: ElevatedButton(
                onPressed: () {
                  cart.clear();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Cleared cart')));
                },
                child: Text('Clear Cart (${cart.totalItems} items)'),
              ),
            ),
    );
  }

  Product? _productById(String id) {
    final allProducts = [
      Product(id: 'p1', name: 'Laptop', price: 1200),
      Product(id: 'p2', name: 'Phone', price: 799),
      Product(id: 'p3', name: 'Headphones', price: 199),
    ];
    return allProducts.firstWhere(
      (p) => p.id == id,
      orElse: () => Product(id: '', name: '', price: 0),
    );
  }
}
