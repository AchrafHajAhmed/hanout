import 'package:flutter/material.dart';
import 'package:hanout/color.dart';
import 'package:hanout/screen/processus_de_commande/Chekout.dart'; // Ensure the path is correct
import 'package:hanout/widget/elevated_button.dart';
import 'order_item.dart';

class MethodeDePaiement extends StatefulWidget {
  final String orderId;
  final double totalAchat;
  final double livraison;
  final List<OrderItem> orderItems; // Add orderItems parameter

  MethodeDePaiement({
    Key? key,
    required this.orderId,
    required this.totalAchat,
    required this.livraison,
    required this.orderItems, // Initialize orderItems
  }) : super(key: key);

  @override
  _MethodeDePaiementState createState() => _MethodeDePaiementState();
}

class _MethodeDePaiementState extends State<MethodeDePaiement> {
  String _paymentMethod = 'online_payment';

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
                'Méthode de paiement',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w900,
                  fontSize: 32.0,
                ),
              ),
            ),
          ),
          ListTile(
            title: Text('Paiement en ligne'),
            trailing: Radio<String>(
              value: 'online_payment',
              groupValue: _paymentMethod,
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value!;
                });
              },
              activeColor: AppColors.secondaryColor,
            ),
          ),
          ListTile(
            title: Text('Paiement à la livraison'),
            trailing: Radio<String>(
              value: 'cash_on_delivery',
              groupValue: _paymentMethod,
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value!;
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TotalCostScreen(
                  totalAchat: widget.totalAchat,
                  livraison: widget.livraison,
                  paymentMethod: _paymentMethod,
                  orderItems: widget.orderItems,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

