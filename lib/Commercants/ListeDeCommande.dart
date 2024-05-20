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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Liste des Commandes"),
      ),
      body: commercantUid == null
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder(
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

              return ListTile(
                title: Text(data['productName']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quantité: ${data['quantity']}'),
                    Text('Prix: ${data['price']} DT'),
                    Text('Utilisateur: ${data['userUid']}'),
                  ],
                ),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  // Naviguer vers une page de détails de la commande si nécessaire
                },
              );
            },
          );
        },
      ),
    );
  }
}
