import 'package:flutter/material.dart';

class ToastSnackbar extends StatelessWidget {
  String contentText;
  Color color;
  ToastSnackbar({super.key, required this.contentText,required this.color});

  @override
  Widget build(BuildContext context) {
    return SnackBar(content: Text(contentText),backgroundColor: color,);
  }
}
