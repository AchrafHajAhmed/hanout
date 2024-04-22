import 'package:flutter/material.dart';
import 'package:hanout/screen/processus_de_commande/Methode_de_Livraison.dart';

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  List<OrderItem> orderItems = [];

  @override
  Widget build(BuildContext context) {

    final String orderId = 'your_order_id_here';

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Order'),
      ),
      body: ListView.builder(
        itemCount: orderItems.length,
        itemBuilder: (context, index) {
          final item = orderItems[index];
          return ListTile(
            title: Text(item.name),
            subtitle: Text('${item.quantity} x ${item.price} TND'),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => MethodeDeLivraison(orderId: orderId)),
              );
            },
            style: ElevatedButton.styleFrom(
            ),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Checkout',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.black,
                ),
              ),
            ),
          ),
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

