class UserModel{
  String name,email,address,phone;
  UserModel({required this.name,required this.email,required this.address,required this.phone});

  // Convert Json Data to object data
  factory UserModel.fromJson(Map<String,dynamic>json){
    return UserModel(
      name: json['name']??"User",
      email: json['email']??"",
      address: json['address']??"",
      phone: json['phone']??""
    );
  }
}