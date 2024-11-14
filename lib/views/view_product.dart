import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app/models/cart_model.dart';
import 'package:e_commerce_app/providers/cart_provider.dart';
import 'package:e_commerce_app/views/cart_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/discount_constant.dart';
import '../models/product_model.dart';

class ViewProduct extends StatefulWidget {
  const ViewProduct({super.key});

  @override
  State<ViewProduct> createState() => _ViewProductState();
}

class _ViewProductState extends State<ViewProduct> {
  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as ProductsModel;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
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
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: arguments.image,
              height: 300,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    arguments.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 25),
                  ),
                  Row(
                    children: [
                      Text(
                        "₹ ${arguments.old_price}",
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
                        "₹ ${arguments.new_price}",
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
                        "${discountPercent(arguments.old_price, arguments.new_price)} %",
                        style: const TextStyle(fontSize: 20, color: Colors.green),
                      )
                    ],
                  ),
                  arguments.maxQuantity == 0
                      ? const Text(
                          "Out of Stock",
                          style: TextStyle(color: Colors.red),
                        )
                      : Text(
                          "Only ${arguments.maxQuantity} left in stock",
                          style: const TextStyle(color: Colors.green),
                        ),
                  Text(
                    arguments.description,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: arguments.maxQuantity!=0?Row(
        children: [
          SizedBox(
            height: 60,
            width: MediaQuery.of(context).size.width * .5,
            child: ElevatedButton(
              onPressed: () {
                Provider.of<CartProvider>(context, listen: false).addToCart(
                    CartModel(
                        productId: arguments.id,
                        quantity: arguments.maxQuantity));
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
                        productId: arguments.id,
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
