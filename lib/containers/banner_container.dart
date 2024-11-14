import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BannerContainer extends StatefulWidget {
  final String image, category;
  const BannerContainer(
      {super.key, required this.image, required this.category});

  @override
  State<BannerContainer> createState() => _BannerContainerState();
}

class _BannerContainerState extends State<BannerContainer> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>Navigator.pushNamed(context,"/specific",arguments: {
        "name":widget.category
      }),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        height: 200,
        child: CachedNetworkImage(
          imageUrl: widget.image,
          fit: BoxFit.cover,
        )
      ),
    );
  }
}
