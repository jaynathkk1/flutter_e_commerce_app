import 'package:e_commerce_app/controllers/db_services.dart';
import 'package:e_commerce_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final formKey=GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    final user = Provider.of<UserProvider>(context,listen: false);
    _nameController.text = user.name;
    _emailController.text =user.email;
    _addressController.text =user.address;
    _phoneController.text =user.phone;
    print(" email: ${user.email}");
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Profile'),),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15, top: 50),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 80,
                    child: TextFormField(
                      controller: _nameController,
                      validator: (v) {
                        if (v!.isEmpty) {
                          return "User Name Cannot Empty";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5)),
                          hintText: 'User Name',
                          labelText: 'User Name',
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5))),
                    ),
                  ),
                  SizedBox(
                    height: 80,
                    child: TextFormField(
                      controller: _emailController,
                      readOnly: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Email  cannot Empty';
                        }
                        if (!RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+./=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$")
                            .hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        // Add more specific validation logic here
                        return null;
                      },
                      decoration: InputDecoration(
                          suffixIcon: const Icon(Icons.email),
                          border: InputBorder.none,
                          fillColor: Colors.grey.shade200,
                          filled: true,
                          labelText: 'Email',
                          ),
                    ),
                  ),
                  SizedBox(
                    height: 90,
                    child: TextFormField(
                      controller: _phoneController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a Phone';
                        }
                        if(value.length>9 && value.length<10){
                          return 'Please enter 10 Digit Number';
                        }
                        // Add more specific validation logic here
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5)),
                          hintText: 'Phone Number ',
                          labelText: 'Phone Number'),
                    ),
                  ),
                  SizedBox(
                    height: 130,
                    child: TextFormField(
                      controller: _addressController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a Address';
                        }
                        // Add more specific validation logic here
                        return null;
                      },
                      maxLines: 3,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5)),
                          hintText: 'Address ',
                          labelText: 'Address'),
                    ),
                  ),
                  SizedBox(
                    height: 60,
                    width: MediaQuery.of(context).size.width * .9,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white),
                      onPressed: () async {
                        if(formKey.currentState!.validate()){
                          final data={
                            "name":_nameController.text,
                            "email":_emailController.text,
                            "address":_addressController.text,
                            "phone":_phoneController.text
                          };
                          await DbServices().updateUserData(extraData: data);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green,content: Text("Updated Successfully !")));
                          Navigator.pop(context);
                        }
                      },
                      child: const Text(
                        'Update Profile',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ));
  }
}
