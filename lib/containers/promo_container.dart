import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_commerce_app/controllers/db_services.dart';
import 'package:e_commerce_app/models/promos_banner_model.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PromoContainer extends StatefulWidget {
  const PromoContainer({super.key});

  @override
  State<PromoContainer> createState() => _PromoContainerState();
}

class _PromoContainerState extends State<PromoContainer> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
          stream: DbServices().readBanner(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<PromosAndBannersModel> promos =
                  PromosAndBannersModel.fromJsonList(snapshot.data!.docs);
              if (promos.isEmpty) {
                return const SizedBox();
              } else {
                return CarouselSlider(
                    items: promos
                        .map((promo) => GestureDetector(
                        onTap:(){
                          Navigator.pushNamed(context, "/specific",arguments: {
                            "name":promo.category
                          });
                        },child: CachedNetworkImage(imageUrl: promo.image,height: 200,width: 400,fit: BoxFit.fill,)
                    //Image.network(promo.image,height: 200,width:400,fit: BoxFit.fill,),
                    ))
                        .toList(),
                    options: CarouselOptions(
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 5),
                      aspectRatio: 16/8,
                      viewportFraction: 1,
                      enlargeCenterPage: true,
                      scrollDirection: Axis.horizontal
                    ));
              }
            } else {
              return Shimmer(
                  gradient: LinearGradient(
                      colors: [Colors.grey.shade400, Colors.green]),
                  child: const SizedBox(
                    height: 300,
                    width: double.infinity,
                  ));
            }
          });
  }
}
