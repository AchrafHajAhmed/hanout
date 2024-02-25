import 'package:flutter/material.dart';

class textbutton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;

  textbutton({required this.buttonText, required this.onPressed});

  @override
  Widget build(BuildContext context) {
       SizedBox(height: 20);
       return TextButton(
         onPressed: onPressed,
         child: Text(buttonText),
    );
  }
}
