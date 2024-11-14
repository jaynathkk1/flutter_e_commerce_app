import 'package:cloud_firestore/cloud_firestore.dart';

class CartModel{
  String productId;
  int quantity;
  CartModel({required this.productId,required this.quantity});

  // Convert Json to Object

  factory CartModel.fromJson(Map<String,dynamic>json){
    return CartModel(productId: json['productId']??"", quantity: json['quantity']??0);
  }
  
  //list cart Data 
  static List<CartModel> toJsonList(List<QueryDocumentSnapshot>list){
    return list.map((e)=>CartModel.fromJson(e.data() as Map<String,dynamic>)).toList();
  }
}