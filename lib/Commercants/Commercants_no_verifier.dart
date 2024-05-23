import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hanout/screen/authentification/log_in.dart';
import 'package:hanout/color.dart';

class MerchantVerificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset('assets/logo.png', height: 50),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/verification.svg',
                  height: 191,
                  width: 164,
                ),
                SizedBox(height: 25),
                Text(
                  'Votre compte est en cours de vérification.',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: InkWell(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignIn()),
                );
              },
              child: Row(
                children: [
                  Icon(
                    Icons.exit_to_app,
                    color: AppColors.primaryColor,
                  ),
                  Text(
                    'Se déconnecter',
                    style: TextStyle(color: AppColors.primaryColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

