
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/controllers/db_services.dart';
import 'package:e_commerce_app/models/user_Model.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  StreamSubscription<DocumentSnapshot>? _userSubscription;
  String name="User";
  String email="";
  String address="";
  String phone="";
  UserProvider(){
    loadUserData();
   }
  // Get All User Details
  void loadUserData() {
    _userSubscription?.cancel();
    _userSubscription=DbServices().readUserData().listen((snapshot){
      //print(snapshot.data());
      final UserModel data=UserModel.fromJson(snapshot.data() as Map<String,dynamic>);
      name=data.name;
      print(name);
      email=data.email;
      print(email);
      address=data.address;
      phone=data.phone;
      notifyListeners();
    });
  }
  void cancelProvider(){
    _userSubscription?.cancel();
  }
  @override
  void dispose() {
    cancelProvider();
    super.dispose();
  }
}
