import 'package:flutter/material.dart';

import '../controllers/db_services.dart';
import '../models/coupon_model.dart';

class DiscountPage extends StatefulWidget {
  const DiscountPage({super.key});

  @override
  State<DiscountPage> createState() => _DiscountPageState();
}

class _DiscountPageState extends State<DiscountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discount & Offer'),),
      body: StreamBuilder(stream: DbServices().readDiscount(), builder: (context,snapshot){
        if(snapshot.hasData){
          List<CouponModel> discounts = CouponModel.fromJsonList(snapshot.data!.docs);
          if(discounts.isEmpty){
            return const SizedBox();
          }else{
            return ListView.builder(
              itemCount: discounts.length,
                itemBuilder: (context,index){
              return ListTile(
                title: Text(discounts[index].code),
                subtitle: Text(discounts[index].desc),
              );
            });
          }
        }else{
          return const SizedBox();
        }
      }),
    );
  }
}
