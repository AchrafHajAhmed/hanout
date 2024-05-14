import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hanout/screen/authentification/log_in.dart';
import 'package:hanout/color.dart';
import 'package:hanout/Commercants/Commercants_no_verifier.dart';
import 'package:hanout/widget/elevated_button.dart';

class MerchantRefusedPage extends StatelessWidget {
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
                  'assets/refuse.svg',
                  height: 191,
                  width: 164,
                ),
                SizedBox(height: 20),
                Text(
                  'Votre demande a été refusée à cause de : ',
                  style: TextStyle(fontSize: 13),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.upload),
                      onPressed: () async {
                        final picker = ImagePicker();
                        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          // Image sélectionnée, faire quelque chose avec elle
                          print('Chemin de l\'image sélectionnée : ${pickedFile.path}');
                        }
                      },
                    ),
                    Flexible(
                      child: Text(
                        'Upload les photos de la carte CIN et du Matricule fiscale',
                        overflow: TextOverflow.visible, // Permet au texte de déborder si nécessaire
                      ),
                    ),
                  ],
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
          Padding(
            padding: const EdgeInsets.only(bottom: 26.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: MyElevatedButton(
                buttonText: 'Confirm',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MerchantVerificationPage()),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

