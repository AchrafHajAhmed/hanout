import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hanout/color.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hanout/widget/bottom_commercants.dart';
import 'package:hanout/Commercants/ajouter_produit.dart';

class CommercantsMarket extends StatefulWidget {
  @override
  _CommercantsMarketState createState() => _CommercantsMarketState();
}

class _CommercantsMarketState extends State<CommercantsMarket> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void updateProductAvailability(String documentId, bool newAvailability) async {
    await FirebaseFirestore.instance.collection('products')
        .doc(documentId)
        .update({'available': newAvailability});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(newAvailability ? 'Produit maintenant disponible' : 'Produit maintenant non disponible')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset('assets/logo.png', height: 50,),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('produit').where('available', isEqualTo: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Une erreur s\'est produite'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('assets/Market.svg', height: 202),
                  SizedBox(height: 20),
                  Text('Your market is empty'),
                ],
              ),
            );
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['name']),
                subtitle: Text(data['description']),
                trailing: Text('${data['price']} DT'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Modifier la disponibilité'),
                      content: Text('Voulez-vous changer la disponibilité de ce produit?'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Annuler'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        TextButton(
                          child: Text('Confirmer'),
                          onPressed: () {
                            updateProductAvailability(document.id, !(data['available'] as bool));
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AjouterProduit()));
        },
        child: Icon(Icons.add),
        backgroundColor: AppColors.primaryColor,
      ),
      bottomNavigationBar: CommercantsBottomNavigationBar(
        currentIndex: _currentIndex,
        onItemSelected: _onTabSelected,
      ),
    );
  }
}

