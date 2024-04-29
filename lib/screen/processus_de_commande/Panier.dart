import 'package:flutter/material.dart';
import 'package:hanout/screen/processus_de_commande/Methode_de_Livraison.dart';
import 'package:hanout/widget/elevated_button.dart';
import 'package:uuid/uuid.dart';

class Panier extends StatefulWidget {
  @override
  _PanierState createState() => _PanierState();
}

class _PanierState extends State<Panier> {
  List<OrderItem> orderItems = [];

  double calculateTotalAchat() {
    double totalAchat = 0.0;
    for (var item in orderItems) {
      totalAchat += item.quantity * item.price;
    }
    return totalAchat;
  }

  @override
  Widget build(BuildContext context) {
    final Uuid uuid = Uuid();
    final String orderId = uuid.v4();
    final double totalAchat = calculateTotalAchat();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset('assets/logo.png', height: 50),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Your Order',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w900,
                  fontSize: 32.0,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: orderItems.length,
              itemBuilder: (context, index) {
                final item = orderItems[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('${item.quantity} x ${item.price.toStringAsFixed(2)} TND'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(40.0),
        child: MyElevatedButton(
          buttonText: 'Checkout',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MethodeDeLivraison(orderId: orderId, totalAchat: totalAchat),
              ),
            );
          },
        ),
      ),
    );
  }
}

class OrderItem {
  String name;
  int quantity;
  double price;

  OrderItem({required this.name, required this.quantity, required this.price});
}


