import 'package:e_commerce_app/containers/category_button.dart';
import 'package:e_commerce_app/controllers/db_services.dart';
import 'package:e_commerce_app/models/category_model.dart';
import 'package:flutter/material.dart';

class CategoriesContainer extends StatefulWidget {
  const CategoriesContainer({super.key});

  @override
  State<CategoriesContainer> createState() => _CategoriesContainerState();
}

class _CategoriesContainerState extends State<CategoriesContainer> {
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
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories
                      .map((cat) =>
                          CategoryButton(imgPath: cat.image, name: cat.name))
                      .toList(),
                ),
              );
            }
          } else {
            return const SizedBox();
          }
        });
  }
}
