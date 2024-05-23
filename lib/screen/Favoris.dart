import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hanout/widget/bottom_navigation_bar.dart';

class Favori extends StatefulWidget {
  const Favori({Key? key}) : super(key: key);

  @override
  State<Favori> createState() => _FavoriState();
}

class _FavoriState extends State<Favori> {
  List<Map<String, dynamic>> favorites = [];

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

  void removeFromFavorites(String productId, String commercantId) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({
        'favorites.$commercantId': FieldValue.arrayRemove([productId]),
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc('$commercantId\_$productId')
          .delete();

      setState(() {
        favorites.removeWhere((favorite) => favorite['productId'] == productId);
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Produit retiré des favoris'),
        duration: Duration(seconds: 1),
      ));
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
            physics: NeverScrollableScrollPhysics(),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              var favorite = favorites[index];
              return Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    CachedNetworkImage(
                      imageUrl: favorite['productImage'],
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      width: 50,
                      height: 50,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(favorite['productName'], style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Commerçant: ${favorite['merchantName']}'),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),
                      onPressed: () => removeFromFavorites(favorite['productId'], favorite['merchantId']),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: MyBottomNavigationBar(
        currentIndex: 1,
        onItemSelected: (index) {
        },
      ),
    );
  }
}
