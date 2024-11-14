import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersModel{
  String id,email,name,phone,status,userId,address;
  int discount,total,createdAt;
  List<OrderProductModel> products;
  OrdersModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.status,
    required this.userId,
    required this.address,
    required this.discount,
    required this.total,
    required this.createdAt,
    required this.products
  });

  //convert json to object
  factory OrdersModel.fromJson(Map<String, dynamic> json,String id){
    return OrdersModel(
        id: id??"",
        email: json['email']??"",
        name: json['name']??"",
        phone: json['phone']??"",
        status: json['status']??"",
        userId: json['userId']??"",
        address: json['address']??"",
        discount: json['discount']??0,
        total: json['total']??0,
        createdAt: json['createdAt']??0,
        products: List<OrderProductModel>.from(json['products'].map((e)=>OrderProductModel.fromJson(e)))
    );
  }

  // Convert List<QueryDocumentSnapshot> to List<ordersModel>
  static List<OrdersModel> fromJsonList(List<QueryDocumentSnapshot>list){
    return list.map((e)=>OrdersModel.fromJson(e.data() as Map<String,dynamic>,e.id)).toList();
  }

}

class OrderProductModel{
  String id,name,image;
  int quantity,singlePrice,totalPrice;

  OrderProductModel({
    required this.id,
    required this.name,
    required this.image,
    required this.quantity,
    required this.singlePrice,
    required this.totalPrice,
  });

  //Convert to json to object
  factory OrderProductModel.fromJson(Map<String,dynamic>json){
    return OrderProductModel(
        id: json['id']??"",
        name: json['name']??"",
        image: json['image']??"",
        quantity: json['quantity']??0,
        singlePrice: json['singlePrice']??0,
        totalPrice: json['totalPrice']??0
    );}
}