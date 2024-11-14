import 'package:e_commerce_app/controllers/db_services.dart';
import 'package:e_commerce_app/models/coupon_model.dart';
import 'package:flutter/material.dart';

class DiscountContainer extends StatefulWidget {
  const DiscountContainer({super.key});

  @override
  State<DiscountContainer> createState() => _DiscountContainerState();
}

class _DiscountContainerState extends State<DiscountContainer> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(stream: DbServices().readDiscount(), builder: (context,snapshot){
      if(snapshot.hasData){
        List<CouponModel> discounts = CouponModel.fromJsonList(snapshot.data!.docs);
        if(discounts.isEmpty){
          return const SizedBox();
        }else{
          return GestureDetector(
            onTap: ()=>Navigator.pushNamed(context,"/discount"),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 18),
              margin: const EdgeInsets.symmetric(horizontal: 6,vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(20)
              ),
              child: Column(children: [
                Text("Use Coupon Code: ${discounts[0].code}",style: TextStyle(color: Colors.blue.shade500,fontWeight: FontWeight.bold,fontSize: 18),),
                Text(discounts[0].desc,style: TextStyle(color: Colors.blue.shade300,fontWeight: FontWeight.w500,fontSize: 12),)
              ],),
            ),
          );
        }
      }else{
        return const SizedBox();
      }
    });
  }
}
