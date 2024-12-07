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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Best Deals',style: TextStyle(fontSize: 35),),
                  IconButton(onPressed: (){
                    Navigator.pushNamed(context, "/search");
                  }, icon:  Icon(Icons.search_outlined,size: 35,color: Colors.grey.shade500,))
                ],
              ),),
              PromoContainer(),
              DiscountContainer(),
              CategoriesContainer(),
              HomePageMakerContainer()
            ],
          ),
        ),
      ),
    );
  }
}
