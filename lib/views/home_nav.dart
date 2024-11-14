import 'package:e_commerce_app/providers/cart_provider.dart';
import 'package:e_commerce_app/views/cart_page.dart';
import 'package:e_commerce_app/views/order_page.dart';
import 'package:e_commerce_app/views/profile_page.dart';
import 'package:e_commerce_app/views/user_home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeNav extends StatefulWidget {
  const HomeNav({super.key});

  @override
  State<HomeNav> createState() => _HomeNavState();
}

class _HomeNavState extends State<HomeNav> {

  int selectedIndex=0;
  List pages=[
    const UserHome(),
    const OrdersPage(),
    const CartPage(),
    const ProfilePage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
          onTap: (value){
            setState(() {
              selectedIndex=value;
            });
          },
          currentIndex: selectedIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey.shade400,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: <BottomNavigationBarItem>[
        const BottomNavigationBarItem(icon: Icon(Icons.home_outlined),label: 'Home'),
        const BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined),label: 'Orders'),
        BottomNavigationBarItem(icon: Consumer<CartProvider>(builder: (context,value,child){
          if(value.carts.isNotEmpty){
            return Badge(
              backgroundColor: Colors.green,
              child: const Icon(Icons.shopping_cart_outlined),
              label: Text(value.carts.length.toString(),),
            );
          }
            return const Icon(Icons.shopping_cart_outlined);
        },),label: 'Cart'),
        const BottomNavigationBarItem(icon: Icon(Icons.account_circle_outlined),label: 'Profile'),
      ]),
    );
  }
}
