import 'package:cloud_firestore/cloud_firestore.dart';

class ProductsModel{
  String name;
  String description;
  String image;
  int old_price;
  int new_price;
  String category;
  String id;
  int maxQuantity;
  ProductsModel({
    required this.name,
    required this.description,
    required this.image,
    required this.old_price,
    required this.new_price,
    required this.category,
    required this.id,
    required this.maxQuantity,
});

  // convert object from json data
  factory ProductsModel.fromJson(Map<String, dynamic>json,String id){
    return ProductsModel(
        name: json['name']??"",
        description: json['description']??"No Description",
        image: json['image']??"",
        old_price: json['old_price']??0,
        new_price: json['new_price']??0,
        category: json['category'],
        id: id??"",
        maxQuantity: json['maxQuantity']??0
    );
  }

  // Convert List<QueryDocumentSnapshot> to List<ProductModel>
  static List<ProductsModel> fromJsonList(List<QueryDocumentSnapshot> list){
    return list.map((e)=> ProductsModel.fromJson(e.data() as Map<String, dynamic>,e.id)).toList();
  }
}