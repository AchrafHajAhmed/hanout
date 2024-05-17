import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hanout/Commercants/ajouter_produit.dart';
import 'package:hanout/widget/bottom_commercants.dart';

class CommercantsMarket extends StatefulWidget {
  @override
  _CommercantsMarketState createState() => _CommercantsMarketState();
}

class _CommercantsMarketState extends State<CommercantsMarket> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    String? commercantUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset('assets/logo.png', height: 50), // Remplacer par le chemin de votre logo
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('produitdisponible').where('uid', isEqualTo: commercantUid).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data?.docs.isEmpty ?? true) {
            return Center(child: Text('No products found'));
          }
          return ListView.separated(
            padding: EdgeInsets.all(8.0),
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (context, index) => Divider(color: Colors.grey),
            itemBuilder: (context, index) {
              DocumentSnapshot document = snapshot.data!.docs[index];
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CachedNetworkImage(
                      imageUrl: data['imageUrl'],
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      width: 70,
                      height: 70,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                data['name'],
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(width: 10),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Disponible',
                                  style: TextStyle(color: Colors.black, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Text(
                            'DESCRIPTION:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            data['description'],
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'PRIX: ${data['price']} DT',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AjouterProduit()));
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: CommercantsBottomNavigationBar(
        currentIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }
}



