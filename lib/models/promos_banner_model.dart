import 'package:cloud_firestore/cloud_firestore.dart';

class PromosAndBannersModel{
  final String title;
  final String category;
  final String image;
  final String id;

  PromosAndBannersModel({required this.title, required this.category, required this.image, required this.id});

  // Convert Json to Object Data
  factory PromosAndBannersModel.fromJson(Map<String,dynamic>json,String id){
    return PromosAndBannersModel(
        title: json['title']??"",
        category: json['category']??"",
        image: json['image'],
        id: id);
  }
  // List<QueryDocumentSnapshot> to List Model
  static List<PromosAndBannersModel> fromJsonList(
      List<QueryDocumentSnapshot> list
      ){
    return list.map((e)=>PromosAndBannersModel.fromJson(e.data() as Map<String,dynamic>,e.id)).toList();
  }

}