import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hanout/screen/Favoris.dart';
import 'package:hanout/screen/authentification/log_in.dart';
import 'package:hanout/widget/bottom_navigation_bar.dart';
import 'package:hanout/screen/My_Account/Commande.dart';
import 'package:hanout/screen/My_Account/Parametre.dart';
import 'package:hanout/color.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hanout/screen/Favoris.dart';
import 'package:hanout/screen/authentification/log_in.dart';
import 'package:hanout/widget/bottom_navigation_bar.dart';
import 'package:hanout/screen/My_Account/Commande.dart';
import 'package:hanout/screen/My_Account/Parametre.dart';
import 'package:hanout/color.dart';

class MyAccount extends StatefulWidget {
  @override
  _MyAccountState createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  String userEmail = '';
  String userName = '';
  bool isPaymentButtonClicked = false;
  String orderId = 'example-order-id'; // Example order ID

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email ?? '';
      });

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot userData = await firestore.collection('users').doc(user.uid).get();
      setState(() {
        Map<String, dynamic>? data = userData.data() as Map<String, dynamic>?;
        if (data != null) {
          userName = data['name'] ?? '';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset('assets/logo.png', height: 50),
      ),
      body: buildUserInfo(),
      bottomNavigationBar: MyBottomNavigationBar(
        currentIndex: 3,
        onItemSelected: (index) {},
      ),
    );
  }

  Widget buildUserInfo() {
    double screenWidth = MediaQuery.of(context).size.width;
    return ListView(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            width: screenWidth,
            height: 69,
            decoration: BoxDecoration(
              color: Color(0xFFF4F3F3),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListTile(
              title: Text('$userName',
                  style: TextStyle(
                    color: AppColors.secondaryColor,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  )),
              subtitle: Text('$userEmail',
                  style: TextStyle(
                    color: AppColors.thirdColor,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  )),
              trailing: Icon(
                Icons.account_circle_outlined,
                size: 40,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildIconButton(context, Icons.favorite_outline, () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => Favori()));
              }),
              buildIconButton(context, Icons.notifications_active_outlined, () {}),
              buildIconButton(context, Icons.manage_accounts_outlined, () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Parametre()));
              }),
              buildIconButton(context, Icons.payment_outlined, () {}),
            ],
          ),
        ),
        ListTile(
          leading: Icon(
            Icons.list,
            color: AppColors.thirdColor,
          ),
          title: Text('Mes commandes'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Commande(orderId: orderId), // Pass the orderId here
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(
            Icons.info_outline,
            color: AppColors.thirdColor,
          ),
          title: Text('À propos'),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(
            Icons.help_outline,
            color: AppColors.thirdColor,
          ),
          title: Text('Aide et FAQ'),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(
            Icons.exit_to_app,
            color: AppColors.thirdColor,
          ),
          title: Text('Se déconnecter'),
          onTap: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => SignIn()));
          },
        ),
        SizedBox(height: 50),
        Image.asset('assets/logo.png', height: 200),
      ],
    );
  }

  Widget buildIconButton(
      BuildContext context, IconData icon, VoidCallback onPressed) {
    return Container(
      width: 70,
      height: 69,
      decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(5.0)),
      child: IconButton(
        icon: Icon(
          icon,
          color: AppColors.thirdColor,
        ),
        onPressed: onPressed,
      ),
    );
  }
}



