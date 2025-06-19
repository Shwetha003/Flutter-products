import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';
import 'cart_page.dart';
import 'package:go_router/go_router.dart';
import '../models/auth_model.dart';
import '../services/product_service.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

/* final List<Product> products = [
    Product(id: 'p1', name: 'Laptop', price: 1200),
    Product(id: 'p2', name: 'Phone', price: 799),
    Product(id: 'p3', name: 'Headphones', price: 199),
  ];
  */

class _ProductsPageState extends State<ProductsPage> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = ProductService.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    //final cart = Provider.of<CartProvider>(context);
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          // cart
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CartPage()),
                ),
              ),
              if (cart.totalItems > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.red,
                    child: Text(
                      cart.totalItems.toString(),
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),

          // menu for logout
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'logout') {
                // clear auth state and go back home
                context.read<AuthModel>().logout();
                context.go('/welcome');
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),

      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: \${snapshot.error}'));
          } else {
            final products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      cart.addItem(product);
                    },
                  ),
                );
              },
            );
          }
        },
      ),

      /*  body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (_, i) {
          final prod = products[i];
          final qty = cart.items[prod.id] ?? 0;
          return ListTile(
            title: Text(prod.name),
            subtitle: Text('\$${prod.price.toStringAsFixed(2)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: qty > 0 ? () => cart.removeItem(prod) : null,
                ),
                Text(qty.toString()),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => cart.addItem(prod),
                ),
              ],
            ),
          );
        },
      ),
      */
    );
  }
}
