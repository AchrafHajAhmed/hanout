import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class acceuil extends StatefulWidget {
  const acceuil({Key? key}) : super(key: key);

  @override
  _acceuilState createState() => _acceuilState();
}

class _acceuilState extends State<acceuil> {
  String? _username;

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  Future<void> fetchUsername() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _username = userDoc.get('name');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('acceuil'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_username != null)
                Text('Bonjour, $_username '),
              SizedBox(height: 20.0),

            ],
          ),
        ),
      ),
    );
  }
}
