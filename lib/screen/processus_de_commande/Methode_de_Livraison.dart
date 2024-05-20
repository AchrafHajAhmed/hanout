import 'package:flutter/material.dart';
import 'package:hanout/color.dart';
import 'package:hanout/screen/processus_de_commande/Confirmation localisation.dart';
import 'package:hanout/screen/processus_de_commande/Methode_de_Paiement.dart'; // Ensure the correct path
import 'package:hanout/widget/elevated_button.dart';
import 'order_item.dart'; // Ensure this path is correct

class MethodeDeLivraison extends StatefulWidget {
  final String orderId;
  final double totalAchat;
  final List<OrderItem> orderItems; // Add orderItems parameter

  MethodeDeLivraison({
    Key? key,
    required this.orderId,
    required this.totalAchat,
    required this.orderItems, // Initialize orderItems
  }) : super(key: key);

  @override
  _MethodeDeLivraisonState createState() => _MethodeDeLivraisonState();
}

class _MethodeDeLivraisonState extends State<MethodeDeLivraison> {
  String _deliveryMethod = 'delivery';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset('assets/logo.png', height: 50),
      ),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Méthode de livraison',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w900,
                  fontSize: 32.0,
                ),
              ),
            ),
          ),
          ListTile(
            title: Text('Livraison'),
            trailing: Radio<String>(
              value: 'delivery',
              groupValue: _deliveryMethod,
              onChanged: (value) {
                setState(() {
                  _deliveryMethod = value!;
                });
              },
              activeColor: AppColors.secondaryColor,
            ),
          ),
          ListTile(
            title: Text('Retrait de magasin'),
            trailing: Radio<String>(
              value: 'store_pickup',
              groupValue: _deliveryMethod,
              onChanged: (value) {
                setState(() {
                  _deliveryMethod = value!;
                });
              },
              activeColor: AppColors.secondaryColor,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(40.0),
        child: MyElevatedButton(
          buttonText: 'Confirm',
          onPressed: () {
            if (_deliveryMethod == 'delivery') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ConfirmationLocalisation()),
              ).then((deliveryCost) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MethodeDePaiement(
                      orderId: widget.orderId,
                      totalAchat: widget.totalAchat,
                      livraison: deliveryCost ?? 0,
                      orderItems: widget.orderItems, // Pass orderItems here
                    ),
                  ),
                );
              });
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MethodeDePaiement(
                    orderId: widget.orderId,
                    totalAchat: widget.totalAchat,
                    livraison: 0,
                    orderItems: widget.orderItems, // Pass orderItems here
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}




