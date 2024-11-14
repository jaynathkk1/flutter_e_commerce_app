import 'package:cloud_firestore/cloud_firestore.dart';

class CouponModel{
  String id;
  String code;
  int discount;
  String desc;
  CouponModel({required this.id,required this.code,required this.discount,required this.desc});

  //Convert Object to Json
  Map<String,dynamic> toJson(){
    return {
      "code":code,
      "discount":discount,
      "desc":desc
    };
  }
  // Convert Json To Object Data
  factory CouponModel.fromJson(Map<String,dynamic>data, String id){
    return CouponModel(
        id: id??"",
        code: data['code']??"",
        discount: data['discount']??"",
        desc: data['desc']??"");
  }

  // List<QueryDocumentSnapshot> List to List<CouponModel>
  static List<CouponModel> fromJsonList(List<QueryDocumentSnapshot>list){
    return list.map((e)=>CouponModel.fromJson(e.data() as Map<String,dynamic>,e.id)).toList();
  }
}