import 'package:flutter/material.dart';

class MyElevatedButton extends StatelessWidget {
  var elevatedbutton;
  final VoidCallback onPressed;

  MyElevatedButton({required this.elevatedbutton, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    SizedBox(height: 20);
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(elevatedbutton),
    );
  }
}