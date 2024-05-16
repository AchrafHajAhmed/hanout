import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ModificationsProduitPage extends StatelessWidget {
  final String productId;

  ModificationsProduitPage({required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifications de produit'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('produit').doc(productId).snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Produit introuvable'));
          }
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nom: ${data['name']}'),
                Text('Description: ${data['description']}'),
                Text('Prix: ${data['price']}'),
                SizedBox(height: 20),
                Text('Disponibilité actuelle: ${data['available'] ? 'Disponible' : 'Non disponible'}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
