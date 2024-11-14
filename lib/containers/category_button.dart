import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CategoryButton extends StatefulWidget {
  final String imgPath,name;
  const CategoryButton({super.key, required this.imgPath, required this.name});

  @override
  State<CategoryButton> createState() => _CategoryButtonState();
}

class _CategoryButtonState extends State<CategoryButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>Navigator.pushNamed(context,"/specific",arguments: {
        "name":widget.name
      }),
      child: Container(
        padding: const EdgeInsets.all(4),
        margin: const EdgeInsets.all(4),
        height: 95,
        width: 95,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CachedNetworkImage(imageUrl: widget.imgPath,height: 60,),
            SizedBox(
            height: 18,
                child: Text("${widget.name.substring(0,1).toUpperCase()}${widget.name.substring(1)}"))
          ],
        ),
      ),
    );
  }
}
