import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hanout/color.dart';
import 'package:hanout/widget/bottom_navigation_bar.dart';


class Favori extends StatefulWidget {
  const Favori({Key? key}) : super(key: key);

  @override
  State<Favori> createState() => _FavoriState();
}

class _FavoriState extends State<Favori> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset(
          'assets/logo.png',
          height: 50,
        ),
      ),
      body:ListView(
          children: [
          SizedBox(height: 20),
      Container(
        width: screenWidth,
        height: 69,
        color: AppColors.primaryColor,
        child: Row(
          children: [
            SizedBox(width: 10),
            Icon(
              Icons.favorite_outline,
              color: Colors.white,
              size: 40,
            ),
            SizedBox(width: 10),
            Text(
              'Favoris',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w900,
                fontSize: 24.0,
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 20),
      StreamBuilder(
        stream: FirebaseFirestore.instance.collection('favoris').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Erreur: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              return ListTile(
                leading: Image.network(data['imageURL']),
                title: Text(data['nomProduit']),
                subtitle: Text('Commerçant: ${data['nomCommercant']}'),
              );
            }).toList(),
          );
        },
      ),
  ]),
      bottomNavigationBar: MyBottomNavigationBar(
      currentIndex: 2,
      onItemSelected: (index) {
        print("Selected index: $index");
      },
    ),);
  }
}

