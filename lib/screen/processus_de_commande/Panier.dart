import 'package:flutter/material.dart';
import 'package:hanout/screen/processus_de_commande/Methode_de_Livraison.dart';
import 'package:hanout/widget/elevated_button.dart';
import 'package:uuid/uuid.dart';
import 'order_item.dart';
import 'package:hanout/screen/processus_de_commande/Methode_de_Paiement.dart';

import 'package:flutter/material.dart';
import 'order_item.dart'; // Ensure this path is correct
import 'package:hanout/screen/processus_de_commande/Methode_de_Livraison.dart';
import 'package:hanout/widget/elevated_button.dart';

class Panier extends StatefulWidget {
  final List<OrderItem> orderItems;

  Panier({Key? key, required this.orderItems}) : super(key: key);

  @override
  _PanierState createState() => _PanierState();
}

class _PanierState extends State<Panier> {
  List<OrderItem> orderItems = [];

  @override
  void initState() {
    super.initState();
    orderItems = widget.orderItems;
  }

  double calculateTotalAchat() {
    double totalAchat = 0.0;
    for (var item in orderItems) {
      totalAchat += item.quantity * item.price;
    }
    return totalAchat;
  }

  void _incrementQuantity(int index) {
    setState(() {
      orderItems[index].quantity += 1;
    });
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (orderItems[index].quantity > 1) {
        orderItems[index].quantity -= 1;
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      orderItems.removeAt(index);
    });
  }

  void _goToMethodeDeLivraison() {
    final double totalAchat = calculateTotalAchat();
    final String orderId = 'example-order-id'; // Example order ID

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MethodeDeLivraison(
          orderId: orderId,
          totalAchat: totalAchat,
          orderItems: orderItems, // Pass orderItems here
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  subtitle: Row(
                    children: [
                      Text('${item.quantity} x ${item.price.toStringAsFixed(2)} TND'),
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () => _decrementQuantity(index),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => _incrementQuantity(index),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => _removeItem(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Total: ${totalAchat.toStringAsFixed(2)} TND',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(40.0),
        child: MyElevatedButton(
          buttonText: 'Checkout',
          onPressed: _goToMethodeDeLivraison,
        ),
      ),
    );
  }
}
