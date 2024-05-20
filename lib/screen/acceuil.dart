import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hanout/screen/processus_de_commande/Panier.dart';
import 'package:hanout/widget/bottom_navigation_bar.dart';
import 'package:hanout/widget/map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hanout/screen/processus_de_commande/commercants_produit.dart';  // Import CommercantProduitsPage
import 'package:hanout/screen/processus_de_commande/order_item.dart';
import 'package:hanout/color.dart';

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
  List<OrderItem> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _cityName = widget.cityName;
    fetchCommercants();
  }

  void fetchCommercants() async {
    // Fetch commercants from Firestore
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

      QuerySnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('produitdisponible')
          .where('uid', isEqualTo: doc.id)
          .get();
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
        'id': doc.id,
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

  void _addToCart(OrderItem item) {
    setState(() {
      _cartItems.add(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset('assets/logo.png', height: 50),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Panier(orderItems: _cartItems),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _cityName,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 20,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Recherche produits, superettes, commercants',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.filter_list),
                    label: Text('Trier'),
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('La plus proche'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('Notes'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('Ouvrir'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                  ),
                ],
              ),
            ),
            //CustomMap(), // Uncomment this if you have a CustomMap widget
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _commercants.length,
              itemBuilder: (context, index) {
                final commercant = _commercants[index];
                return ListTile(
                  leading: Icon(Icons.storefront_outlined, color: AppColors.secondaryColor, size: 70),
                  title: Text(commercant['name']),
                  subtitle: Text('${commercant['products']}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('4.2', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      Text('notes', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommercantProduitsPage(
                          commercantId: commercant['id'],
                          commercantName: commercant['name'],
                          addToCart: _addToCart,
                        ),
                      ),
                    );
                  },
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
