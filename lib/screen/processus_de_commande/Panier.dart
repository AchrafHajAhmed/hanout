import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hanout/screen/processus_de_commande/Methode_de_Livraison.dart';
import 'package:hanout/widget/elevated_button.dart';
import 'order_item.dart';

class Panier extends StatefulWidget {
  final List<OrderItem> orderItems;
  final String commercantUid;

  Panier({Key? key, required this.orderItems, required this.commercantUid}) : super(key: key);

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
    final String orderId = 'example-order-id';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MethodeDeLivraison(
          orderId: orderId,
          totalAchat: totalAchat,
          orderItems: orderItems,
          commercantUid: widget.commercantUid,
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
                'Votre Commande',
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
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        width: 50,
                        height: 50,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('${item.quantity} x ${item.price.toStringAsFixed(2)} TND'),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.remove, color: Colors.red),
                        onPressed: () => _decrementQuantity(index),
                      ),
                      Text('${item.quantity}'),
                      IconButton(
                        icon: Icon(Icons.add, color: Colors.green),
                        onPressed: () => _incrementQuantity(index),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.grey),
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
          buttonText: 'Valider la Commande',
          onPressed: _goToMethodeDeLivraison,
        ),
      ),
    );
  }
}

