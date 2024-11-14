import 'package:e_commerce_app/controllers/db_services.dart';
import 'package:e_commerce_app/models/product_model.dart';
import 'package:flutter/material.dart';

import '../constants/discount_constant.dart';

class SpecificProducts extends StatefulWidget {
  const SpecificProducts({super.key});

  @override
  State<SpecificProducts> createState() => _SpecificProductsState();
}

class _SpecificProductsState extends State<SpecificProducts> {
  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "${args["name"].substring(0, 1).toUpperCase()}${args["name"].substring(1)}"),
      ),
      body: StreamBuilder(
          stream: DbServices().readProducts(args["name"]),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<ProductsModel> products =
                  ProductsModel.fromJsonList(snapshot.data!.docs);
              if (products.isEmpty) {
                return const Center(child: Text('Product Not Found'));
              } else {
                return GridView.builder(
                    itemCount: products.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(
                              context, "/view_product",
                              arguments: product),
                          child: Card(
                            color: Colors.grey.shade200,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.grey.shade200,
                                      image: DecorationImage(
                                          image: NetworkImage(product.image),
                                          fit: BoxFit.fitHeight)),
                                )),
                                Text(
                                  product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "₹ ${product.old_price}",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w500,
                                          decoration:
                                              TextDecoration.lineThrough),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "₹ ${product.new_price}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    const Icon(
                                      Icons.arrow_downward,
                                      color: Colors.green,
                                      size: 1,
                                    ),
                                    Text(
                                      "${discountPercent(product.old_price, product.new_price)} %",
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.green),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    });
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}
