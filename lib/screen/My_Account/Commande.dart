import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Commande extends StatelessWidget {
  final String orderId;

  Commande({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Order Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('orders').doc(orderId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Order not found.'));
          }

          var orderData = snapshot.data!.data() as Map<String, dynamic>?;

          if (orderData == null) {
            return Center(child: Text('Order data is null.'));
          }

          var orderItems = orderData['orderItems'] as List<dynamic>?;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order ID: $orderId', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('Merchant Name: ${orderData['merchantName'] ?? 'Unknown'}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                Text('Status: ${orderData['status'] ?? 'Unknown'}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                Divider(thickness: 2),
                Text('Items:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                orderItems != null && orderItems.isNotEmpty
                    ? Column(
                  children: orderItems.map((item) {
                    var itemName = item['name'] ?? 'Unknown';
                    var itemQuantity = item['quantity'] ?? 'Unknown';
                    var itemPrice = item['price'] ?? 'Unknown';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text('$itemName x $itemQuantity - $itemPrice TND'),
                    );
                  }).toList(),
                )
                    : Text('No items found.'),
                Divider(thickness: 2),
                Text('Total Cost: ${orderData['totalCost'] ?? 'Unknown'} TND', style: TextStyle(fontSize: 16)),
                Text('Service Fee: ${orderData['serviceFee'] ?? 'Unknown'} TND', style: TextStyle(fontSize: 16)),
                Text('Tax VAT: ${orderData['taxVAT'] ?? 'Unknown'} TND', style: TextStyle(fontSize: 16)),
                Text('Grand Total: ${orderData['grandTotal'] ?? 'Unknown'} TND', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      ),
    );
  }
}
