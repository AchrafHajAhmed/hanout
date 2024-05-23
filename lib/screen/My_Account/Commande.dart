import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Commande extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Mes commandes'),
        ),
        body: Center(
          child: Text('Aucun utilisateur n\'est actuellement connecté.'),
        ),
      );
    }

    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset('assets/logo.png', height: 50),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: screenWidth,
            height: 69,
            color: Colors.yellow,
            child: Row(
              children: [
                SizedBox(width: 10),
                Icon(
                  Icons.list,
                  color: Colors.white,
                  size: 40,
                ),
                SizedBox(width: 10),
                Text(
                  'Mes commandes',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w900,
                    fontSize: 24.0,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('userId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erreur : ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Aucune commande trouvée.'));
                }

                var orders = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    var orderData = orders[index].data() as Map<String, dynamic>;
                    var orderItems = orderData['orderItems'] as List<dynamic>;

                    Color statusColor;
                    String status = orderData['status'];
                    if (status == 'waiting') {
                      statusColor = Colors.grey;
                    } else if (status == 'refused') {
                      statusColor = Colors.red;
                    } else if (status == 'accepted') {
                      statusColor = Colors.green;
                    } else {
                      statusColor = Colors.black;
                    }

                    Color backgroundColor;
                    if (status == 'waiting') {
                      backgroundColor = Colors.grey.shade300;
                    } else if (status == 'refused') {
                      backgroundColor = Colors.red.shade300;
                    } else if (status == 'accepted') {
                      backgroundColor = Colors.green.shade300;
                    } else {
                      backgroundColor = Colors.white;
                    }

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          Text('Statut : $status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Text('Articles :', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ...orderItems.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              '${item['name']} x ${item['quantity']} - ${item['price'].toStringAsFixed(3)} TND',
                              style: TextStyle(fontSize: 16),
                            ),
                          )),
                          Divider(thickness: 2),
                          Text('Coût total : ${orderData['totalCost'].toStringAsFixed(3)} TND', style: TextStyle(fontSize: 16)),
                          Text('Frais de service : ${orderData['serviceFee'].toStringAsFixed(3)} TND', style: TextStyle(fontSize: 16)),
                          Text('TVA : ${orderData['taxVAT'].toStringAsFixed(3)} TND', style: TextStyle(fontSize: 16)),
                          Text('Total : ${orderData['grandTotal'].toStringAsFixed(3)} TND', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

