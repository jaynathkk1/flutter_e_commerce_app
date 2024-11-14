import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/cart_model.dart';

class DbServices {
  final _firestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;

  // USER  DATA

  // Save User Data
  Future saveUserData({required String email, required String name}) async {
    try {
      Map<String, dynamic> data = {"name": name, "email": email};
      await _firestore.collection('shop_users').doc(user!.uid).set(data);
    } catch (e) {
      print(" Error occurred saving data ${e.toString()}");
    }
  }

  // Update User data
  Future updateUserData({required Map<String, dynamic> extraData}) async {
    await _firestore.collection('shop_users').doc(user!.uid).update(extraData);
  }

  //
  //Read User Data
  Stream<DocumentSnapshot> readUserData() {
    print(user!.uid);
    print(user!.email);
    return _firestore.collection("shop_users").doc(user!.uid).snapshots();
  }

  //Read Promos and banner
  Stream<QuerySnapshot> readPromo() {
    return _firestore.collection('shop_promos').snapshots();
  }

  //Banner
  Stream<QuerySnapshot> readBanner() {
    return _firestore.collection('shop_banners').snapshots();
  }

  //DISCOUNT
  // Read discount
  Stream<QuerySnapshot> readDiscount() {
    return _firestore
        .collection('shop_coupon')
        .orderBy("discount", descending: true)
        .snapshots();
  }

  //Verify Coupon Code
  Future<QuerySnapshot> verifyDiscount({required String code}) {
    //print('Searching code $code');
    return _firestore
        .collection('shop_coupon')
        .where("code", isEqualTo: code)
        .get();
  }

  //READ CATEGORIES
  // CATEGORIES
  Stream<QuerySnapshot> readCategories() {
    return _firestore
        .collection('shop_categories')
        .orderBy('priority', descending: true)
        .snapshots();
  }

  // Read Product Data
  Stream<QuerySnapshot> readProducts(String category) {
    return _firestore
        .collection('shop_products')
        .where('category', isEqualTo: category.toLowerCase())
        .snapshots();
  }
  // Read Product Data
  Future<QuerySnapshot> fetchProducts() {
    return _firestore
        .collection('shop_products').get();
  }

  //Search product by product id
  Stream<QuerySnapshot> searchProducts(List<String> docIds) {
    return _firestore
        .collection('shop_products')
        .where(FieldPath.documentId, whereIn: docIds)
        .snapshots();
  }

  //reduce Quantity of product from products
  Future reduceProduct({required String docId, required int quantity}) async {
    await _firestore
        .collection('shop_products')
        .doc(docId)
        .update({"maxQuantity": FieldValue.increment(-quantity)});
  }

  //CART
  //read cart data each user
  Stream<QuerySnapshot> readUserCart() {
    return _firestore
        .collection('shop_users')
        .doc(user?.uid)
        .collection('cart')
        .snapshots();
  }

  //add Product to Cart
  Future addToCart({required CartModel cartData}) async {
    try {
      // update
      await _firestore
          .collection('shop_users')
          .doc(user?.uid)
          .collection('cart')
          .doc(cartData.productId)
          .update({
        "productId": cartData.productId,
        "quantity": FieldValue.increment(1)
      });
    } on FirebaseException catch (e) {
      print('Firebase exception ${e.toString()}');
      // insert set the Data
      await _firestore
          .collection('shop_users')
          .doc(user?.uid)
          .collection('cart')
          .doc(cartData.productId)
          .set({"productId": cartData.productId, "quantity": 1});
    }
  }

  //Delete Item from cart
  Future deleteItemFromCart({required String productId}) async {
    await _firestore
        .collection('shop_users')
        .doc(user?.uid)
        .collection('cart')
        .doc(productId)
        .delete();
  }

  //decrease item from cart
  Future decreaseCount({required String productId}) async {
    await _firestore
        .collection('shop_users')
        .doc(user?.uid)
        .collection('cart')
        .doc(productId)
        .update({"quantity": FieldValue.increment(-1)});
  }

  // Empty cart
  Future emptyCart() async {
    await _firestore
        .collection('shop_users')
        .doc(user?.uid)
        .collection('cart')
        .get()
        .then((value) {
      for (DocumentSnapshot ds in value.docs) {
        ds.reference.delete();
      }
    });
  }

  //ORDERS USERS

  //create new order
  Future createOrder({required Map<String, dynamic> data}) async {
    await _firestore.collection('shop_orders').add(data);
  }

  //update order
  Future updateOrderStatus(
      {required String docId, required Map<String, dynamic> data}) async {
    await _firestore.collection('shop_orders').doc(docId).update(data);
  }

  //Delete order from order list
  Future deleteOrder({required String orderId}) async {
    await _firestore.collection('shop_orders').doc(orderId).delete();
  }

  //read order data from current user
  Stream<QuerySnapshot> readOrders() {
    return _firestore
        .collection('shop_orders')
        .where("userId", isEqualTo: user!.uid)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }
}
