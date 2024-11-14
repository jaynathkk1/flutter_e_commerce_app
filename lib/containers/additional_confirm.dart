import 'package:flutter/material.dart';

class AdditionalConfirm extends StatefulWidget {
  final String title;
  final VoidCallback onYes,onNo;
  const AdditionalConfirm({super.key, required this.title, required this.onYes, required this.onNo});

  @override
  State<AdditionalConfirm> createState() => _AdditionalConfirmState();
}

class _AdditionalConfirmState extends State<AdditionalConfirm> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Are you Sure'),
      content: Text(widget.title),
      actions: [
        TextButton(onPressed: widget.onNo, child: const Text('No')),
        TextButton(onPressed: widget.onYes, child: const Text('Yes')),
      ],
    );
  }
}
