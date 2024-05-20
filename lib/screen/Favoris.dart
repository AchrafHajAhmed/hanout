import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hanout/widget/bottom_navigation_bar.dart';


class Favori extends StatefulWidget {
  const Favori({Key? key}) : super(key: key);

  @override
  State<Favori> createState() => _FavoriState();
}

class _FavoriState extends State<Favori> {
  late List<Map<String, dynamic>> favorites = [];

  @override
  void initState() {
    super.initState();
    fetchFavorites();
  }

  void fetchFavorites() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      QuerySnapshot<Map<String, dynamic>> favoritesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();
      setState(() {
        favorites = favoritesSnapshot.docs.map((doc) => doc.data()).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset('assets/logo.png', height: 50),
      ),
      body: ListView(
        children: [
          SizedBox(height: 20),
          Container(
            width: screenWidth,
            height: 69,
            color: Colors.yellow,
            child: Row(
              children: [
                SizedBox(width: 10),
                Icon(
                  Icons.favorite,
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
          ListView.builder(
            shrinkWrap: true,
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              var favorite = favorites[index];
              return ListTile(
                leading: Image.network(favorite['productImage']),
                title: Text(favorite['productName']),
                subtitle: Text('Commerçant: ${favorite['merchantName']}'),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: MyBottomNavigationBar(
        currentIndex: 2,
        onItemSelected: (index) {},
      ),
    );
  }
}




