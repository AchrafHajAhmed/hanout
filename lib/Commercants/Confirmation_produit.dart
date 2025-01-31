import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hanout/widget/elevated_button.dart';
import 'package:hanout/color.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ConfirmModifications extends StatefulWidget {
  final Map<String, bool> modifiedProducts;

  ConfirmModifications({required this.modifiedProducts});

  @override
  _ConfirmModificationsState createState() => _ConfirmModificationsState();
}

class _ConfirmModificationsState extends State<ConfirmModifications> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  List<DocumentSnapshot> modifiedProductsDocs = [];

  @override
  void initState() {
    super.initState();
    fetchModifiedProducts();
  }

  void fetchModifiedProducts() async {
    String? commercantUid = FirebaseAuth.instance.currentUser?.uid;
    List<String> productIds = widget.modifiedProducts.keys.toList();
    if (productIds.isNotEmpty) {
      QuerySnapshot querySnapshot = await _firestore.collection('produit').where(FieldPath.documentId, whereIn: productIds).get();
      setState(() {
        modifiedProductsDocs = querySnapshot.docs;
      });
    }
  }

  void updateProductsInFirestore() async {
    String? commercantUid = FirebaseAuth.instance.currentUser?.uid;
    if (commercantUid != null) {
      for (var document in modifiedProductsDocs) {
        bool newAvailability = widget.modifiedProducts[document.id]!;
        await _firestore.collection('produit').doc(document.id).update({'available': newAvailability});

        Map<String, dynamic> productData = document.data() as Map<String, dynamic>;

        if (newAvailability) {
          await _firestore.collection('produitdisponible').doc(document.id).set({
            'available': true,
            'uid': commercantUid,
            'name': productData['name'],
            'price': productData['price'],
            'description': productData['description'],
            'imageUrl': productData['imageUrl'],
          });

          // Fetch interested users
          var interestedUsers = await _firestore
              .collection('users')
              .where('favorites.$commercantUid', arrayContains: document.id)
              .get();

          for (var userDoc in interestedUsers.docs) {
            var userToken = userDoc.data()['token'];
            if (userToken != null) {
              _sendNotification(userToken, productData['name'], commercantUid);
            }
          }
        } else {
          await _firestore.collection('produitdisponible').doc(document.id).delete();
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Les modifications ont été enregistrées.'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  void _sendNotification(String token, String productName, String merchantId) {
    _firebaseMessaging.sendMessage(
      to: token,
      data: {
        'title': 'Produit disponible',
        'body': '$productName est maintenant disponible chez le marchand $merchantId.',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Image.asset('assets/logo.png', height: 50),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: Column(
            children: [
              _buildTopBar(context),
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

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      height: 69,
      color: AppColors.primaryColor,
      child: Row(
        children: [
          SvgPicture.asset('assets/Market.svg', height: 60),
          SizedBox(width: 10),
          Text(
            'Confirmer Produits',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 24.0,
            ),
          ),
        ],
      ),
    );
  }
}






