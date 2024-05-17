import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hanout/Commercants/Commercant_market.dart';
import 'package:hanout/widget/elevated_button.dart';

class ConfirmModifications extends StatefulWidget {
  final Map<String, bool> modifiedProducts;

  ConfirmModifications({required this.modifiedProducts});

  @override
  _ConfirmModificationsState createState() => _ConfirmModificationsState();
}

class _ConfirmModificationsState extends State<ConfirmModifications> {
  List<DocumentSnapshot> modifiedProductsDocs = [];

  @override
  void initState() {
    super.initState();
    fetchModifiedProducts();
  }

  void fetchModifiedProducts() async {
    String? commercantUid = FirebaseAuth.instance.currentUser?.uid;
    List<String> productIds = widget.modifiedProducts.keys.toList();
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('produit').where(FieldPath.documentId, whereIn: productIds).get();
    setState(() {
      modifiedProductsDocs = querySnapshot.docs;
    });
  }

  void updateProductsInFirestore() async {
    String? commercantUid = FirebaseAuth.instance.currentUser?.uid;
    for (var document in modifiedProductsDocs) {
      bool newAvailability = widget.modifiedProducts[document.id]!;
      await FirebaseFirestore.instance.collection('produit').doc(document.id).update({'available': newAvailability});

      Map<String, dynamic> productData = document.data() as Map<String, dynamic>;

      if (newAvailability) {
        await FirebaseFirestore.instance.collection('produitdisponible').doc(document.id).set({
          'available': true,
          'uid': commercantUid,
          'name': productData['name'],
          'price': productData['price'],
          'description': productData['description'],
          'imageUrl': productData['imageUrl'],
        });
      } else {
        await FirebaseFirestore.instance.collection('produitdisponible').doc(document.id).delete();
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Les modifications ont été enregistrées.'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CommercantsMarket()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Confirmer les Modifications"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(child:Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: modifiedProductsDocs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = modifiedProductsDocs[index];
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                bool isAvailable = widget.modifiedProducts[document.id]!;
                return ListTile(
                  title: Text(data['name']),
                  subtitle: Text('${data['price']} Dinar'),
                  trailing: Text(isAvailable ? 'Disponible' : 'Non disponible'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: MyElevatedButton(
              buttonText: 'Confirmer',
              onPressed: updateProductsInFirestore,
            ),
          ),
        ],
      ),
    ));
  }
}


