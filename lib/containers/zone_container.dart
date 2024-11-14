import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app/constants/discount_constant.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../controllers/db_services.dart';
import '../models/product_model.dart';

class ZoneContainer extends StatefulWidget {
  final String category;
  const ZoneContainer({super.key, required this.category});

  @override
  State<ZoneContainer> createState() => _ZoneContainerState();
}

class _ZoneContainerState extends State<ZoneContainer> {

  Widget specialQuotes({required int price,required int dis}){
    int random= Random().nextInt(2);
    List<String> quotes=[
      "Starting at ₹ $price",
      "Get up to Discount $dis%"
    ];
    return Text(quotes[random],style:
      const TextStyle(color: Colors.green),);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: DbServices().readProducts(widget.category),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<ProductsModel> products =
                ProductsModel.fromJsonList(snapshot.data!.docs);
            if (products.isEmpty) {
              return const Center(child: Text('Product Not Found'));
            } else {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                color: Colors.blue.shade50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                            "${widget.category.substring(0, 1).toUpperCase()}${widget.category.substring(1)}"),
                        const Spacer(),
                        IconButton(
                            onPressed: () {
                              Navigator.pushNamed(context, "/specific",
                                  arguments: {"name": widget.category});
                            },
                            icon: const Icon(Icons.arrow_forward_ios)),
                      ],
                    ),
                    // Show Max 4 Products at Time
                    Wrap(
                      spacing: 4,
                      children: [
                        for(int i=0;i<(products.length>4?4:products.length);i++)
                          GestureDetector(
                            onTap: ()=>Navigator.pushNamed(context,"/view_product",arguments: products[i]),
                            child: Container(
                              width: MediaQuery.of(context).size.width*.43,
                              color: Colors.white,
                              height: 180,
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.all(5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CachedNetworkImage(imageUrl: products[i].image,height: 100,),
                                  Text(
                                    products[i].name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  specialQuotes(price: products[i].new_price, dis: int.parse(discountPercent(products[i].old_price, products[i].new_price)))],
                              ),
                            ),
                          )
                      ],
                    )
                  ],
                ),
              );
            }
          } else {
            return Shimmer(
              child: Container(
                height: 400,
                width: double.infinity,
                color: Colors.white,
              ),
              gradient:
                  LinearGradient(colors: [Colors.grey.shade200, Colors.white]),
            );
          }
        });
  }
}
