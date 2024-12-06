import 'package:e_commerce_app/controllers/auth_services.dart';
import 'package:e_commerce_app/firebase_options.dart';
import 'package:e_commerce_app/providers/product_provider.dart';
import 'package:e_commerce_app/views/cart_page.dart';
import 'package:e_commerce_app/providers/cart_provider.dart';
import 'package:e_commerce_app/providers/user_provider.dart';
import 'package:e_commerce_app/views/checkout_page.dart';
import 'package:e_commerce_app/views/discount_page.dart';
import 'package:e_commerce_app/views/home_nav.dart';
import 'package:e_commerce_app/views/login_page.dart';
import 'package:e_commerce_app/views/order_page.dart';
import 'package:e_commerce_app/views/product_search_page.dart';
import 'package:e_commerce_app/views/search_ui.dart';
import 'package:e_commerce_app/views/sign_up.dart';
import 'package:e_commerce_app/views/specific_products.dart';
import 'package:e_commerce_app/views/update_profile.dart';
import 'package:e_commerce_app/views/view_product.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  Stripe.publishableKey = dotenv.env["STRIPE_PUBLIC_KEY"]!;
  Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
  Stripe.urlScheme = 'flutterstripe';
  await Stripe.instance.applySettings();

  final fcmToken = await FirebaseMessaging.instance.getToken();
  print(fcmToken);

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => CartProvider(),
    ),
    ChangeNotifierProvider(create: (context) => ProductProvider())
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProvider(),
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        routes: {
          "/": (context) => const CheckUser(),
          "/home": (context) => const HomeNav(),
          "/login": (context) => const LoginPage(),
          "/signup": (context) => const SignupPage(),
          "/update_profile": (context) => const UpdateProfile(),
          "/discount": (context) => const DiscountPage(),
          "/specific": (context) => const SpecificProducts(),
          "/view_product": (context) => const ViewProduct(),
          "/cart": (context) => const CartPage(),
          "/checkout": (context) => const CheckoutPage(),
          "/order": (context) => const OrdersPage(),
          "/view_order": (context) => const ViewOrder(),
          "/complete": (context) => const CompleteOrder(),
          "/search": (context) => const ProductSearchScreen(),
          "/product_search": (context) => ProductSearchPage()
        },
      ),
    );
  }
}

class CheckUser extends StatefulWidget {
  const CheckUser({super.key});

  @override
  State<CheckUser> createState() => _CheckUserState();
}

class _CheckUserState extends State<CheckUser> {
  @override
  void initState() {
    super.initState();
    AuthServices().isLoggedIn().then((value) {
      if (value) {
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        Navigator.pushReplacementNamed(context, "/login");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
