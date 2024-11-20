import 'package:e_commerce_app/containers/cart_container.dart';
import 'package:e_commerce_app/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart',style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),),scrolledUnderElevation: 0,
        forceMaterialTransparency: true,
        actions: [
          IconButton(onPressed: (){
            Navigator.pushNamed(context, "/cart");
          }, icon: const Icon(Icons.refresh))
        ],
      ),
      body: Consumer<CartProvider>(builder: (context,value,child){
        if(value.carts.isEmpty){
          return const Center(child: Text('No Item in Cart '));
        }
        else{
          if(value.products.isNotEmpty){
              return ListView.builder(
                  itemCount: value.carts.length,
                  itemBuilder: (context, index) {
                    return CartContainer(
                        image: value.products[index].image,
                        name: value.products[index].name,
                        productId: value.products[index].id,
                        new_price: value.products[index].new_price,
                        old_price: value.products[index].old_price,
                        maxQuantity: value.products[index].maxQuantity,
                        selectedQuantity: value.carts[index].quantity);
                  });
            }
          else {
            return const Text("No items in cart");
          }
          }
        },
      ),
      bottomNavigationBar: Consumer<CartProvider>(builder: (context,value,child){
        if(value.carts.isEmpty){
          return const SizedBox();
        }else{
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Text("Total Cost: ₹${value.totalCost}",style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 14),),
                 const SizedBox(width: 30,),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white
                    ),
                      onPressed: (){
                      Navigator.pushNamed(context, "/checkout");
                      },
                      child: const Text('Processing To Checkout'))
                ],
              ),
            ),
          );
        }
      },),
    );
  }
}
