import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/discount_constant.dart';
import '../models/cart_model.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import 'cart_page.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  ProductDetailScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name),
      actions: [
        IconButton(onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const CartPage()));
        }, icon: Consumer<CartProvider>(
          builder: (context, value, child) {
            if (value.carts.isNotEmpty) {
              return Badge(
                backgroundColor: Colors.green,
                child: const Icon(Icons.shopping_cart_outlined),
                label: Text(
                  value.carts.length.toString(),
                ),
              );
            }
            return const Icon(Icons.shopping_cart_outlined);
          },
        ))
      ],),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(product.image),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(product.name, style: TextStyle(fontSize: 24)),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 25),
                  ),
                  Row(
                    children: [
                      Text(
                        "₹ ${product.oldPrice}",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.lineThrough),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Text(
                        "₹ ${product.newPrice}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      const Icon(
                        Icons.arrow_downward,
                        color: Colors.green,
                      ),
                      Text(
                        "${discountPercent(product.oldPrice, product.newPrice)} %",
                        style: const TextStyle(fontSize: 20, color: Colors.green),
                      )
                    ],
                  ),
                  product.maxQuantity == 0
                      ? const Text(
                    "Out of Stock",
                    style: TextStyle(color: Colors.red),
                  )
                      : Text(
                    "Only ${product.maxQuantity} left in stock",
                    style: const TextStyle(color: Colors.green),
                  ),
                  Text(
                    product.description,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: product.maxQuantity!=0?Row(
        children: [
          SizedBox(
            height: 60,
            width: MediaQuery.of(context).size.width * .5,
            child: ElevatedButton(
              onPressed: () {
                Provider.of<CartProvider>(context, listen: false).addToCart(
                    CartModel(
                        productId: product.id,
                        quantity: product.maxQuantity));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    backgroundColor: Colors.green,
                    content: Text('Add Item To Cart Successfully!')));
              },
              child: const Text(
                "Add to Cart",
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(),
              ),
            ),
          ),
          SizedBox(
            height: 60,
            width: MediaQuery.of(context).size.width * .5,
            child: ElevatedButton(
              onPressed: () {
                Provider.of<CartProvider>(context, listen: false).addToCart(
                    CartModel(
                        productId: product.id,
                        quantity: 1));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    backgroundColor: Colors.green,
                    content: Text('Add Item To Cart Successfully!')));
                Navigator.pushNamed(context, "/checkout");
              },
              child: const Text(
                "Buy now",
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(),
              ),
            ),
          ),
        ],
      ):const SizedBox(),
    );
  }
}
