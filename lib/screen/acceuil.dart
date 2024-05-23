import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hanout/screen/processus_de_commande/Panier.dart';
import 'package:hanout/widget/bottom_navigation_bar.dart';
import 'package:hanout/widget/map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hanout/screen/processus_de_commande/commercants_produit.dart';
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
  String? _selectedCommercantUid;

  @override
  void initState() {
    super.initState();
    _cityName = widget.cityName;
    fetchCommercants();
  }

  void fetchCommercants() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('commercants').get();
    Set<Marker> markers = {};
    List<Map<String, dynamic>> commercants = [];

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      if (data == null) continue;

      double? latitude = double.tryParse(data['latitude']?.toString() ?? '');
      double? longitude = double.tryParse(data['longitude']?.toString() ?? '');
      String? name = data['name'];

      if (latitude == null || longitude == null || name == null) continue;

      QuerySnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('produitdisponible')
          .where('uid', isEqualTo: doc.id)
          .get();
      String products = productSnapshot.docs.map((doc) {
        var productData = doc.data() as Map<String, dynamic>?;
        return productData?['name'] ?? '';
      }).join(', ');

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

    setState(() {
      _markers = markers;
      _commercants = commercants;
    });
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        _cityName,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 20,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down,),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.shopping_cart, size:25,),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Panier(orderItems: _cartItems, commercantUid: _selectedCommercantUid ?? ''),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Recherche produits, superettes, commerçants',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            Container(
              height: 50,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
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
            ),
            MyMap(
              height: MediaQuery.of(context).size.height * 1 / 5,
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
                    setState(() {
                      _selectedCommercantUid = commercant['id'];
                    });
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




