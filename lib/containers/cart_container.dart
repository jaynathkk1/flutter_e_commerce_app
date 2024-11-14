import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app/models/cart_model.dart';
import 'package:e_commerce_app/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/discount_constant.dart';

class CartContainer extends StatefulWidget {
  final String image, name, productId;
  final int new_price, old_price, maxQuantity, selectedQuantity;

  const CartContainer(
      {super.key,
      required this.image,
      required this.name,
      required this.productId,
      required this.new_price,
      required this.old_price,
      required this.maxQuantity,
      required this.selectedQuantity});

  @override
  State<CartContainer> createState() => _CartContainerState();
}

class _CartContainerState extends State<CartContainer> {
  int count = 1;
  increaseCount(int max) async {
    if (count == max) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(backgroundColor: Colors.red,content: Text('Maximum Quantity Reached')));
      return;
    } else {
      Provider.of<CartProvider>(context, listen: false)
          .addToCart(CartModel(productId: widget.productId, quantity: count));
      setState(() {
        count++;
        print(count);
      });
    }
  }

  //decrease item count
  decreaseCount()async{
    if(count>1){
      Provider.of<CartProvider>(context,listen: false).decreaseCount(widget.productId);
      setState(() {
        count--;
      });
    }
  }
  @override
  void initState() {
    count=widget.selectedQuantity;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(10),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 80,
                width: 80,
                child: widget.image==null?const Icon(Icons.image):CachedNetworkImage(imageUrl: widget.image)
              ),
              const SizedBox(width: 10,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.name,
                    style: const TextStyle(fontSize: 16),overflow: TextOverflow.ellipsis,maxLines: 2,),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("₹ ${widget.old_price}",style: TextStyle(fontSize: 14,color: Colors.grey.shade700,fontWeight: FontWeight.w500,decoration: TextDecoration.lineThrough),),
                        const SizedBox(width: 15,),
                        Text("₹ ${widget.new_price}",style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                        const SizedBox(width: 5,),
                        const Icon(Icons.arrow_downward,color: Colors.green,),
                        Text("${discountPercent(widget.old_price, widget.new_price)} %",style: const TextStyle(fontSize: 16,color: Colors.green),)
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(onPressed: (){
                Provider.of<CartProvider>(context,listen: false).deleteItem(widget.productId);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.red,content: Text('Item Deleted from Cart Successfully!')));
              }, icon: const Icon(Icons.delete,color: Colors.red,))
          ],),
          Row(children: [
            const SizedBox(child: Text('Quantity :',style: TextStyle(fontWeight: FontWeight.bold),)),
            Container(
              height: 40,
              width: 40,
              margin: const EdgeInsets.only(right: 10,left: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade300
              ),
              child: IconButton(onPressed: (){
                decreaseCount();
              }, icon: const Icon(Icons.remove)),
            ),
            Text('${widget.selectedQuantity}',style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
            Container(
              height: 40,
              width: 40,
              margin: const EdgeInsets.only(right: 10,left: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade300
              ),
              child: IconButton(onPressed: (){
                increaseCount(widget.maxQuantity);
              }, icon: const Icon(Icons.add)),
            ),
            const Spacer(),
            const Text('Total : ',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
            Text("₹${widget.new_price*count}",style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
          ],)
        ],),
      ),
    );
  }
}
