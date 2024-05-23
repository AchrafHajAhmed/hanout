import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ListeCommande extends StatefulWidget {
  @override
  _ListeCommandeState createState() => _ListeCommandeState();
}

class _ListeCommandeState extends State<ListeCommande> {
  String? commercantUid;

  @override
  void initState() {
    super.initState();
    getCommercantUid();
  }

  void getCommercantUid() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      setState(() {
        commercantUid = user.uid;
      });
    }
  }

  void updateOrderStatus(String orderId, String status) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({'status': status});
  }

  Future<String> getUserName(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return userDoc['name'] ?? 'N/A';
      } else {
        print('User document does not exist for userId: $userId');
        return 'N/A';
      }
    } catch (e) {
      print('Error fetching user name for userId: $userId - $e');
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset('assets/logo.png', height: 50),
      ),
      body: commercantUid == null
          ? Center(child: CircularProgressIndicator())
          : Column(
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
                  'Liste des Commandes',
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
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('commercantUid', isEqualTo: commercantUid)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Une erreur est survenue.'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Aucune commande trouvée.'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot document = snapshot.data!.docs[index];
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

                    String status = data['status'] ?? 'unknown';
                    String userId = data['userID'] ?? 'N/A';

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

                    bool isStatusFinal = status == 'accepted' || status == 'refused';

                    return FutureBuilder<String>(
                      future: getUserName(userId),
                      builder: (context, userNameSnapshot) {
                        if (userNameSnapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (userNameSnapshot.hasError) {
                          return Center(child: Text('Erreur de chargement du nom d\'utilisateur.'));
                        }

                        String userName = userNameSnapshot.data ?? 'N/A';

                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...data['orderItems'].map<Widget>((item) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Produit : ${item['name']}', style: TextStyle(fontSize: 16)),
                                    Text('Quantité : ${item['quantity']}', style: TextStyle(fontSize: 16)),
                                    Text('Prix : ${item['price'].toStringAsFixed(3)} DT', style: TextStyle(fontSize: 16)),
                                    SizedBox(height: 10),
                                  ],
                                );
                              }).toList(),
                              SizedBox(height: 10),
                              Text('Statut : $status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: isStatusFinal
                                        ? null
                                        : () {
                                      updateOrderStatus(document.id, 'accepted');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isStatusFinal ? Colors.grey : Colors.green,
                                    ),
                                    child: Text('Accepter'),
                                  ),
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: isStatusFinal
                                        ? null
                                        : () {
                                      updateOrderStatus(document.id, 'refused');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isStatusFinal ? Colors.grey : Colors.red,
                                    ),
                                    child: Text('Refuser'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
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
