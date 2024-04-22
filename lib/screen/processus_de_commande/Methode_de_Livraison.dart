import 'package:flutter/material.dart';

  class MethodeDeLivraison extends StatefulWidget {
  final String orderId; // This would be passed in when navigating to the screen

  MethodeDeLivraison({Key? key, required this.orderId}) : super(key: key);

  @override
  _MethodeDeLivraisonState createState() => _MethodeDeLivraisonState();
  }

  class _MethodeDeLivraisonState extends State<MethodeDeLivraison> {
  String _deliveryMethod = 'delivery'; // Default value

  @override
  Widget build(BuildContext context) {
  return Scaffold(
  appBar: AppBar(
  title: Text('Delivery Method'),
  ),
  body: Column(
  children: <Widget>[
  RadioListTile<String>(
  title: Text('Delivery'),
  value: 'delivery',
  groupValue: _deliveryMethod,
  onChanged: (value) {
  setState(() {
  _deliveryMethod = value ?? 'delivery';
  });
  },
  ),
  RadioListTile<String>(
  title: Text('Store Pickup'),
  value: 'store_pickup',
  groupValue: _deliveryMethod,
  onChanged: (value) {
  setState(() {
  _deliveryMethod = value ?? 'store_pickup';
  });
  },
  ),
  ],
  ),
  bottomNavigationBar: BottomAppBar(
  child: Padding(
  padding: EdgeInsets.all(16.0),
  child: ElevatedButton(
  onPressed: () {
  saveDeliveryMethod();
  },
  child: Text('Confirm'),
  ),
  ),
  ),
  );
  }

  void saveDeliveryMethod() {
  print('Selected delivery method: $_deliveryMethod');

 // );
  }
  }
