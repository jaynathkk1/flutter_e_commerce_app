import 'package:e_commerce_app/containers/banner_container.dart';
import 'package:e_commerce_app/containers/zone_container.dart';
import 'package:e_commerce_app/controllers/db_services.dart';
import 'package:e_commerce_app/models/category_model.dart';
import 'package:e_commerce_app/models/promos_banner_model.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomePageMakerContainer extends StatefulWidget {
  const HomePageMakerContainer({super.key});

  @override
  State<HomePageMakerContainer> createState() => _HomePageMakerContainerState();
}

class _HomePageMakerContainerState extends State<HomePageMakerContainer> {
  int min=0;
  minCalculate(int a,int b){
    return min=a>b?b:a;
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: DbServices().readCategories(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<CategoriesModel> categories =
                CategoriesModel.fromJsonList(snapshot.data!.docs);
            if (categories.isEmpty) {
              return const SizedBox();
            } else {
              return StreamBuilder(
                  stream: DbServices().readBanner(),
                  builder: (context, snapshotBanner) {
                    if (snapshotBanner.hasData) {
                      List<PromosAndBannersModel> banners =
                          PromosAndBannersModel.fromJsonList(
                              snapshotBanner.data!.docs);
                      if (banners.isEmpty) {
                        return const SizedBox();
                      } else {
                        return Column(children: [
                          for(int i=0;i<(minCalculate(snapshot.data!.docs.length, snapshotBanner.data!.docs.length));i++)
                            Column(children: [
                              ZoneContainer(category: snapshot.data!.docs[i]['name']),
                              BannerContainer(image: snapshotBanner.data!.docs[i]['image'], category: snapshotBanner.data!.docs[i]['category'])
                            ],)
                        ],);
                      }
                    } else {
                      return const SizedBox();
                    }
                  });
            }
          } else {
            return Shimmer(
                child: const SizedBox(
                  height: 200,
                  width: double.infinity,
                ),
                gradient: LinearGradient(
                    colors: [Colors.grey.shade200, Colors.white]));
          }
        });
  }
}
