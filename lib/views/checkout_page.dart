import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/controllers/db_services.dart';
import 'package:e_commerce_app/controllers/mailer_service.dart';
import 'package:e_commerce_app/models/orders_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

import '../constants/payment.dart';
import '../providers/cart_provider.dart';
import '../providers/user_provider.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController _couponController = TextEditingController();
  int discount = 0;
  int toPay = 0;
  int percent=0;
  String discountText = "";
  bool paymentSuccessFull=false;

  Map<String,dynamic> dataOfOrders={};

  discountCalculate(int disPercent,int totalCost){
    discount=(disPercent*totalCost) ~/100;
    setState(() {

    });
  }
  Future<void> initPaymentSheet(int cost) async {
    try {
      final user = Provider.of<UserProvider>(context,listen: false);
      // 1. create payment intent on the server
      final data = await createPaymentIntent(name: user.name,
        address: user.address,
        amount:(cost*100).toString()
      );

      // 2. initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          // Set to true for custom flow
          customFlow: false,
          // Main params
          merchantDisplayName: 'Flutter Stripe Store Demo',
          paymentIntentClientSecret: data['client_secret'],
          // Customer keys
          customerEphemeralKeySecret: data['ephemeralKey'],
          customerId: data['id'],
          // Extra options
          applePay: const PaymentSheetApplePay(
            merchantCountryCode: 'US',
          ),
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'US',
            testEnv: true,
          ),
          style: ThemeMode.dark,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,

      ),
      body: SingleChildScrollView(
        child: Consumer<UserProvider>(
          builder: (context, userData, child) => Consumer<CartProvider>(
            builder: (context, cartData, child) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 35,
                      child: Text(
                        'Delivery Details',
                        style:
                            TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * .65,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                   userData.name,
                                  style: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.w600),
                                ),
                                Text(userData.email),
                                Text(userData.address),
                                Text(userData.phone),
                              ],
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/update_profile');
                              },
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: Colors.blue,
                              ))
                        ],
                      ),
                    ),
                    const SizedBox(height: 10,),
                    const SizedBox(
                      height: 35,
                        child: Text('Have a Coupon?')),
                    Row(
                      children: [
                        SizedBox(
                          width:200,
                          child: TextField(
                            controller: _couponController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              hintText: 'Coupon Code',
                              border: InputBorder.none,
                              filled: true,
                              fillColor: Colors.grey.shade200
                            ),
                          ),
                        ),
                        TextButton(onPressed: ()async{
                          QuerySnapshot querySnapshot=await DbServices().verifyDiscount(code: _couponController.text.toUpperCase());
                          if(querySnapshot.docs.isNotEmpty){
                            QueryDocumentSnapshot doc=querySnapshot.docs.first;
                            doc.get('code');
                            percent=doc.get('discount');
                            //print('discount $code');
                            //print('discount $percent');
                            //print('discount $discount');
                            discountCalculate(percent, cartData.totalCost);
                            //access other field as required
                            discountText='Get discount of $percent% applied on checkout';
                          }else{
                            discountText='Not valid code Found,Try another code';
                            discount=0;
                            percent=0;
                          }
                          setState(() {
                          });
                        },
                            child: const Text('Apply'))
                      ],
                    ),
                    const SizedBox(height: 10,),
                    discountText==''?Container():Text(discountText),
                    const Divider(),
                    const SizedBox(height: 10,),
                    Text('Total Quantity Products: ${cartData.totalQuantity}'),
                    Text('Sub Total: ₹${cartData.totalCost}'),
                    const Divider(),
                    discount==0?const SizedBox():Text('Extra Discount: -₹$discount ($percent%)'),
                    const Divider(),
                    Text('Total Payable : ₹${cartData.totalCost-discount}',style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 60,
        padding: const EdgeInsets.all(8),
        child: ElevatedButton(onPressed: ()async{
          final user = Provider.of<UserProvider>(context,listen:false);
          if(user.name==''||user.address==''||user.email==''){
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please Fill your Delivery Details',style: TextStyle(color: Colors.white)),backgroundColor: Colors.red,));
          return;
          }else{
            await initPaymentSheet(Provider.of<CartProvider>(context,listen: false).totalCost-discount);
            try{
              await Stripe.instance.presentPaymentSheet();
              final cart = Provider.of<CartProvider>(context,listen:false);
              User? currentUser=FirebaseAuth.instance.currentUser;
              List products=[];
              for(int i=0;i<cart.products.length;i++){
                products.add({
                  "id":cart.products[i].id,
                  "name":cart.products[i].name,
                  "image":cart.products[i].image,
                  "singlePrice":cart.products[i].new_price,
                  "totalPrice":cart.products[i].new_price*cart.carts[i].quantity,
                  "quantity":cart.carts[i].quantity
                });
              }

              //ORDERS STATUS
              //PAID -paid money by user
              //SHIPPED -item shipped
              //CANCELLED - item cancelled
              //COMPLETE ORDER - Order delivered
              Map<String,dynamic> orderData={
                "userId":currentUser!.uid,
                "name":user.name,
                "email":user.email,
                "address":user.address,
                "phone":user.phone,
                "discount":discount,
                "total":cart.totalCost-discount,
                "products":products,
                "status":'PAID',
                "createdAt":DateTime.now().millisecondsSinceEpoch,
              };
              dataOfOrders=orderData;
              //creating new order
              await DbServices().createOrder(data: orderData);
              //reduce quantity of products
              for(int i=0;i<cart.products.length;i++){
                await DbServices().reduceProduct(docId: cart.products[i].id,
                    quantity: cart.carts[i].quantity);
              }
              //Clear the user cart
              await DbServices().emptyCart();
              paymentSuccessFull=true;
              //close checkout page
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Done ',style: TextStyle(color: Colors.white)),backgroundColor: Colors.green,));
              if(paymentSuccessFull){
                MailerService().sendMailFromGmail(user.email,OrdersModel.fromJson(dataOfOrders, ""));
              }
              Navigator.pushNamed(context, "/complete");
            }catch(e){
              //print('Payment sheet fail error ${e.toString()}');
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Sheet fail',style: TextStyle(color: Colors.white),),backgroundColor: Colors.red,));

            }
          }
        },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue,foregroundColor: Colors.white),
            child: const Text('Processed To Payment')),
      ),
    );
  }
}

class CompleteOrder extends StatefulWidget {
  const CompleteOrder({super.key});

  @override
  State<CompleteOrder> createState() => _CompleteOrderState();
}

class _CompleteOrderState extends State<CompleteOrder> {
  @override
  void initState() {
    super.initState();
    // Delay for 3 seconds, then navigate to Order Screen
    Timer(const Duration(seconds: 3), () {
      Navigator.pushNamed(context, "/order");
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 80,
             backgroundColor: Colors.white,
            child: Icon(Icons.done,color: Colors.green,size: 80,),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextButton(onPressed: (){
              Navigator.pushNamed(context, "/order");
              Navigator.pop(context);
            },
                style: TextButton.styleFrom(backgroundColor: Colors.white,foregroundColor: Colors.blue,),
                child: const Text('Tacking Your Order add Also send Order details on your email')
            ),
          )
        ],
      ),
    );
  }
}
