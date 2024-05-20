import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hanout/screen/authentification/log_in.dart';
import 'package:hanout/widget/bottom_commercants.dart';
import 'package:hanout/screen/My_Account/Parametre.dart';
import 'package:hanout/color.dart';

class CommercantAccount extends StatefulWidget {
  @override
  _CommercantAccountState createState() => _CommercantAccountState();
}

class _CommercantAccountState extends State<CommercantAccount> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String userEmail = '';
  String userName = '';
  bool isPaymentButtonClicked = true;

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
      DocumentSnapshot userData = await firestore.collection('commercants').doc(user.uid).get();
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Image.asset('assets/logo.png', height: 50),
        ),
        body: buildUserInfo(),
        bottomNavigationBar: CommercantsBottomNavigationBar(
          currentIndex: _selectedIndex,
          onItemSelected: _onItemTapped,
        ),
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
              title: Text(
                '$userName',
                style: TextStyle(
                  color: AppColors.secondaryColor,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                '$userEmail',
                style: TextStyle(
                  color: AppColors.thirdColor,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              trailing: Icon(
                Icons.account_circle_outlined,
                size: 40,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        buildListTile(
          context,
          icon: Icons.manage_accounts_outlined,
          title: 'Parametres',
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Parametre()));
          },
        ),
        SizedBox(height: 10,),
        buildListTile(
          context,
          icon: Icons.info_outline,
          title: 'À propos',
          onTap: () {},
        ),
        SizedBox(height: 10,),
        buildListTile(
          context,
          icon: Icons.help_outline,
          title: 'Aide et FAQ',
          onTap: () {},
        ),
        SizedBox(height: 10,),
        buildListTile(
          context,
          icon: Icons.exit_to_app,
          title: 'Se déconnecter',
          onTap: () {
            FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignIn()));
          },
        ),
        SizedBox(height: 50),
        Image.asset('assets/logo.png', height: 200),
      ],
    );
  }

  Widget buildListTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.yellow,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: ListTile(
          leading: Icon(icon, color: AppColors.thirdColor),
          title: Text(title),
          onTap: onTap,
        ),
      ),
    );
  }
}



