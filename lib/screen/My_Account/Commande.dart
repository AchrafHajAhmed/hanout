import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hanout/color.dart';

class Commande extends StatefulWidget {
  @override
  _CommandeState createState() => _CommandeState();
}

class _CommandeState extends State<Commande> {
  late Future<List<CommandeData>> _futureCommandes;
  bool loading = false;


  @override
  void initState() {
    super.initState();
    _futureCommandes = fetchCommandes();
    loading = false;
  }

  Future<List<CommandeData>> fetchCommandes() async {
    String userId = '...';
    loading = false;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('commandes')
        .where('userId', isEqualTo: userId)
        .get();

    List<CommandeData> commandes = [];
    querySnapshot.docs.forEach((doc) {
      commandes.add(CommandeData.fromFirestore(doc));
    });
    setState(() {
      loading = false;
    });

    return commandes;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset('assets/logo.png', height: 50),
      ),
        body: ListView(
            children: [
              Container(
                width: screenWidth,
                height: 69,
                color: AppColors.primaryColor,
                child:const  Row(children: [
                  SizedBox(width: 10),
                  Icon(Icons.list, color: Colors.white,
                    size: 40,),
                   SizedBox(width: 10),
                  Text('Mes commandes',
                    style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w900,
            fontSize: 24.0,
          ),),
      ],),
    ),
      FutureBuilder<List<CommandeData>>(
        future: _futureCommandes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Erreur: ${snapshot.error}');
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index].nom),
                  subtitle: Text(snapshot.data![index].date),
                );
              },
            );
          } else {
            return Text('Aucune commande trouvée');
          }
        },
      ),

    ]));
  }
}

class CommandeData {
  final String nom;
  final String date;

  CommandeData({required this.nom, required this.date});

  factory CommandeData.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CommandeData(
      nom: data['nom'] ?? '',
      date: data['date'] ?? '',
    );
  }
}
