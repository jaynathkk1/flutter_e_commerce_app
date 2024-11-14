import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/controllers/db_services.dart';
import 'package:e_commerce_app/models/cart_model.dart';
import 'package:e_commerce_app/models/product_model.dart';
import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  StreamSubscription<QuerySnapshot>? _cartSubscription;
  StreamSubscription<QuerySnapshot>? _productSubscription;

  bool isLoading = false;

  List<CartModel> carts = [];
  List<String> cartUids = [];
  List<ProductsModel> products = [];
  int totalCost = 0;
  int totalQuantity = 0;

  CartProvider() {
    readCartData();
  }

  // add product to the cart along with quantity
  void addToCart(CartModel cartModel) {
    DbServices().addToCart(cartData: cartModel);
    notifyListeners();
  }

  //Stream and read cart
  void readCartData(){
    isLoading=true;
    _cartSubscription?.cancel();
    _cartSubscription=DbServices().readUserCart().listen((snapshot){
      List<CartModel> cartData=CartModel.toJsonList(snapshot.docs);
      carts=cartData;
      cartUids=[];
      for(int i=0;i<carts.length;i++){
        cartUids.add(carts[i].productId);
        print('cartUids: $cartUids');
      }
      if(carts.isNotEmpty){
        readCartProducts(cartUids);
      }
      isLoading=false;
      notifyListeners();
    });
  }
  // read cart products
  void readCartProducts(List<String>uids){
    _productSubscription?.cancel();
    _productSubscription=DbServices().searchProducts(uids).listen((snapshot){
      List<ProductsModel> productData=ProductsModel.fromJsonList(snapshot.docs);
      products=productData;
      isLoading=false;
      addTotalCost(products, carts);
      calculateTotalQuantity();
      notifyListeners();
    });
  }
  // add cost for all products
  void addTotalCost(List<ProductsModel> products, List<CartModel> carts) {
    totalCost = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0; i < carts.length; i++) {
        totalCost += carts[i].quantity * products[i].new_price;
      }
      notifyListeners();
    });
  }

  // calculate total quantity for products
  void calculateTotalQuantity() {
    totalQuantity = 0;
    for (int i = 0; i < carts.length; i++) {
      totalQuantity += carts[i].quantity;
    }
    print('Total Quantity : $totalQuantity');
    notifyListeners();
  }

  // delete product from cart
  void deleteItem(String productId){
    DbServices().deleteItemFromCart(productId: productId);
    readCartData();
    notifyListeners();
  }
  //Decrease Count from cart
  void decreaseCount(String productId){
    DbServices().decreaseCount(productId: productId);
    notifyListeners();
  }

  //cancel provider
 void cancelProvider(){
    _cartSubscription?.cancel();
    _productSubscription?.cancel();
 }
 @override
  void dispose() {
    cancelProvider();
    super.dispose();
  }
}
