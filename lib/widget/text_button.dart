import 'package:flutter/material.dart';

class MyTextButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;

  MyTextButton({required this.buttonText, required this.onPressed});

  @override
  Widget build(BuildContext context) {
       SizedBox(height: 20);
       return TextButton(
         onPressed: onPressed,
         child: Text(buttonText),
    );
  }
}
