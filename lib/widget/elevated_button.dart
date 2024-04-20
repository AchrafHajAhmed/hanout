import 'package:flutter/material.dart';
import 'package:hanout/color.dart';

class MyElevatedButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final double borderRadius;
  final Color textColor;

  MyElevatedButton({
    required this.buttonText,
    required this.onPressed,
    this.width = 330.0,
    this.height = 50.0,
    this.borderRadius = 8.0,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.ButtonColor,
          width: 2,
        ),
      ),
      child: ElevatedButton(

        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: EdgeInsets.zero,
          backgroundColor: AppColors.ButtonColor,
        ),
        child: Text(
          buttonText,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
