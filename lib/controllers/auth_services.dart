import 'package:e_commerce_app/controllers/db_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  final _auth = FirebaseAuth.instance;

  //create account with email and password
  Future<String> createAccountWithEmail(String name,String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await DbServices().saveUserData(email: email,name: name);
      return "Account created";
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    }
  }

  //login  with email and password
  Future<String> loginWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "Login Successfully!";
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    }
  }

  //logout from  home page
  Future logout() async {
    await _auth.signOut();
  }

  //Reset password with Email
  Future resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return "mail sent";
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    }
  }

  //check user sign in or Not
  Future<bool> isLoggedIn() async {
    var user = _auth.currentUser;
    return user != null;
  }
}
