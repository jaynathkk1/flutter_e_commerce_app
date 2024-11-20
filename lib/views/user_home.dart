import 'package:e_commerce_app/containers/Categories_container.dart';
import 'package:e_commerce_app/containers/discount_container.dart';
import 'package:e_commerce_app/containers/home_page_maker_container.dart';
import 'package:e_commerce_app/containers/promo_container.dart';
import 'package:flutter/material.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Best Deals'),
        actions: [
          IconButton(onPressed: (){
           Navigator.pushNamed(context, "/search");
          }, icon: const Icon(Icons.search_outlined))
        ],
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            PromoContainer(),
            DiscountContainer(),
            CategoriesContainer(),
            HomePageMakerContainer()
          ],
        ),
      )
    );
  }
}
