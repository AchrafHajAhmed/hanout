import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hanout/screen/processus_de_commande/Panier.dart';
import 'package:hanout/widget/bottom_navigation_bar.dart';
import 'package:hanout/widget/map.dart'; // Assurez-vous que ceci pointe vers votre widget de carte personnalisé
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Acceuil extends StatefulWidget {
  final String cityName;

  const Acceuil({Key? key, this.cityName = ''}) : super(key: key);

  @override
  _AcceuilState createState() => _AcceuilState();
}

class _AcceuilState extends State<Acceuil> {
  late String _cityName;
  Set<Marker> _markers = {};
  List<Map<String, dynamic>> _commercants = [];

  @override
  void initState() {
    super.initState();
    _cityName = widget.cityName;
    fetchCommercants();
  }

  void fetchCommercants() async {
    print('Fetching commercants...');
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('commercants').get();
    print('Total commercants fetched: ${querySnapshot.docs.length}');
    Set<Marker> markers = {};
    List<Map<String, dynamic>> commercants = [];

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      if (data == null) {
        print('Data is null for doc id: ${doc.id}');
        continue;
      }

      double? latitude = double.tryParse(data['latitude'] ?? '');
      double? longitude = double.tryParse(data['longitude'] ?? '');
      String? name = data['name'];

      if (latitude == null || longitude == null || name == null) {
        print('Missing or invalid latitude/longitude/name for doc id: ${doc.id}');
        continue;
      }

      // Fetch produit disponible for this commercant
      QuerySnapshot productSnapshot = await FirebaseFirestore.instance.collection('produitdisponible').where('uid', isEqualTo: doc.id).get();
      String products = productSnapshot.docs.map((doc) {
        var productData = doc.data() as Map<String, dynamic>?;
        return productData?['name'] ?? '';
      }).join(', ');

      print('Commercant: $name, Products: $products, Latitude: $latitude, Longitude: $longitude');

      markers.add(
        Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(
            title: name,
            snippet: products,
          ),
        ),
      );

      commercants.add({
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'products': products,
      });
    }

    print('Total markers: ${markers.length}');
    print('Total commercants: ${commercants.length}');

    setState(() {
      _markers = markers;
      _commercants = commercants;
    });

    print('State updated. Total markers: ${_markers.length}, Total commercants: ${_commercants.length}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset('assets/logo.png', height: 50),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  padding: EdgeInsets.only(right: 30),
                  icon: Icon(Icons.shopping_cart, size: 35),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Panier()));
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _cityName,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            CustomMap(
              height: 200,
              screenWidth: MediaQuery.of(context).size.width,
              markers: _markers,
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _commercants.length,
              itemBuilder: (context, index) {
                final commercant = _commercants[index];
                return ListTile(
                  title: Text(commercant['name']),
                  subtitle: Text(commercant['products']),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: MyBottomNavigationBar(
        currentIndex: 0,
        onItemSelected: (index) {},
      ),
    );
  }
}



