import 'package:flutter/material.dart';
import 'package:hanout/color.dart';

class MyTextButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;

  MyTextButton({required this.buttonText, required this.onPressed});

  @override
  Widget build(BuildContext context) {
       SizedBox(height: 20);
       return TextButton(
         onPressed: onPressed,
         child: Text(buttonText,
           style: const TextStyle(
             color: Color(0xFF808080),
             fontFamily: 'Roboto',
             fontWeight: FontWeight.w900,
             fontSize: 12.0,),),
    );
  }
}
