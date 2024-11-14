import 'package:e_commerce_app/providers/cart_provider.dart';
import 'package:e_commerce_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  String name="";
  String email="";
  @override
  void initState() {
    final user =Provider.of<UserProvider>(context,listen: false);
    name=user.name;
    email=user.email;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Consumer<UserProvider>(builder: (context, value, child) {
              return Card(
                child: ListTile(
                  title: Text("User Name: $name"),
                  subtitle: Text("Email: $email"),
                  trailing: IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/update_profile");
                      },
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.blue,
                      )),
                ),
              );
            }),
            const Divider(
              thickness: 1,
              endIndent: 10,
              indent: 10,
            ),
            ListTile(
              onTap: () {
                Navigator.pushNamed(context, "/order");
              },
              leading: const Icon(Icons.local_shipping_outlined),
              title: const Text('Orders'),
            ),
            const Divider(
              thickness: 1,
              endIndent: 10,
              indent: 10,
            ),
            ListTile(
              onTap: (){
                Navigator.pushNamed(context, "/discount");
              },
              leading: const Icon(Icons.discount_outlined),
              title: const Text('Discount & Offer'),
            ),
            const Divider(
              thickness: 1,
              endIndent: 10,
              indent: 10,
            ),
            ListTile(
              onTap: (){
                showDialog(context: context, builder: (context){
                 return AlertDialog(
                   actions:[
                     IconButton(onPressed: (){
                       Navigator.pop(context);
                     }, icon: const Text('OK'))
                   ],content: const Text("Help & Services under Processing")
                   ,);
                });
              },
              leading: const Icon(Icons.support_agent),
              title: const Text('Help & Services'),
            ),
            const Divider(
              thickness: 1,
              endIndent: 10,
              indent: 10,
            ),
            ListTile(
              onTap: () async{

                showDialog(context: context, builder: (context){
                  return AlertDialog(
                    title: const Text('Are you Sure?'),
                    content: const Text('You want Logout from this app'),
                    actions: [
                      TextButton(onPressed: (){
                        Navigator.pop(context);
                      }, child: const Text('Cancel')),
                      TextButton(onPressed: (){
                        Provider.of<UserProvider>(context,listen: false).cancelProvider();
                        Provider.of<CartProvider>(context,listen: false).cancelProvider();
                        Navigator.pushNamedAndRemoveUntil(
                            context, "/login", (route) => true);
                      }, child: const Text('Logout'))
                    ],
                  );
                });
              },
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
