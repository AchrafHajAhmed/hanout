import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hanout/widget/elevated_button.dart';
import 'order_item.dart';

class CommercantProduitsPage extends StatefulWidget {
  final String commercantId;
  final String commercantName;
  final Function(OrderItem) addToCart;

  CommercantProduitsPage({
    required this.commercantId,
    required this.commercantName,
    required this.addToCart,
  });

  @override
  _CommercantProduitsPageState createState() => _CommercantProduitsPageState();
}

class _CommercantProduitsPageState extends State<CommercantProduitsPage> {
  Map<String, int> quantities = {};
  List<Map<String, dynamic>> products = [];
  late Set<String> favorites = {};

  @override
  void initState() {
    super.initState();
    fetchFavorites();
  }

  void fetchFavorites() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      setState(() {
        favorites = Set.from(userSnapshot.get('favorites') ?? []);
      });
    }
  }

  void _incrementQuantity(String productId) {
    setState(() {
      quantities[productId] = (quantities[productId] ?? 0) + 1;
    });
  }

  void _decrementQuantity(String productId) {
    setState(() {
      if (quantities[productId] != null && quantities[productId]! > 0) {
        quantities[productId] = quantities[productId]! - 1;
      }
    });
  }

  void _toggleFavorite(Map<String, dynamic> product) async {
    String productId = product['id'];
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);
      if (favorites.contains(productId)) {
        await userDocRef.update({
          'favorites': FieldValue.arrayRemove([productId]),
        });
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .doc(productId)
            .delete();
        setState(() {
          favorites.remove(productId);
        });
      } else {
        await userDocRef.update({
          'favorites': FieldValue.arrayUnion([productId]),
        });
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .doc(productId)
            .set({
          'productId': productId,
          'productName': product['name'],
          'productPrice': product['price'],
          'productImage': product['imageUrl'],
          'merchantId': widget.commercantId,
          'merchantName': widget.commercantName,
        });
        setState(() {
          favorites.add(productId);
        });
      }
    }
  }

  void _addToCart() {
    for (var product in products) {
      String productId = product['id'];
      int quantity = quantities[productId] ?? 0;
      if (quantity > 0) {
        OrderItem item = OrderItem(
          name: product['name'],
          quantity: quantity,
          price: double.parse(product['price']),
        );
        widget.addToCart(item);
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Produits ajoutés au panier'),
      duration: Duration(seconds: 1),
    ));
  }

  void _confirmOrder() {
    // Logique pour confirmer la commande
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Commande confirmée'),
      duration: Duration(seconds: 1),
    ));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset('assets/logo.png', height: 50),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.yellow),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              // Naviguez vers la page du panier
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.commercantName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('produitdisponible')
                  .where('uid', isEqualTo: widget.commercantId)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Une erreur est survenue.'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Aucun produit trouvé.'));
                }

                products = snapshot.data!.docs.map((doc) {
                  return {
                    'id': doc.id,
                    'name': doc['name'],
                    'price': doc['price'],
                    'imageUrl': doc['imageUrl'],
                  };
                }).toList();

                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    var product = products[index];
                    String productId = product['id'];

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
                            imageUrl: product['imageUrl'],
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
                                Text(product['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('${product['price']} DT'),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove, color: Colors.red),
                                      onPressed: () => _decrementQuantity(productId),
                                    ),
                                    Text('${quantities[productId] ?? 0}'),
                                    IconButton(
                                      icon: Icon(Icons.add, color: Colors.green),
                                      onPressed: () => _incrementQuantity(productId),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              favorites.contains(productId) ? Icons.favorite : Icons.favorite_border,
                              color: favorites.contains(productId) ? Colors.red : null,
                            ),
                            onPressed: () => _toggleFavorite(product),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                MyElevatedButton(
                  buttonText: 'Order',
                  onPressed: _addToCart,
                ),
                SizedBox(height: 10),
                MyElevatedButton(
                  buttonText: 'Confirm',
                  onPressed: _confirmOrder,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
