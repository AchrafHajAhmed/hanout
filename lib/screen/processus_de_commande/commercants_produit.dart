import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hanout/widget/elevated_button.dart';
import 'order_item.dart';
import 'methode_de_livraison.dart';

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
  Set<String> availableProducts = {};
  late Set<String> favorites = {};

  @override
  void initState() {
    super.initState();
    fetchFavorites();
    fetchAllProducts();
  }

  void fetchFavorites() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      setState(() {
        favorites = Set.from(userSnapshot.get('favorites.${widget.commercantId}') ?? []);
      });
    }
  }

  void fetchAllProducts() async {
    QuerySnapshot allProductsSnapshot = await FirebaseFirestore.instance.collection('produit').get();
    QuerySnapshot availableProductsSnapshot = await FirebaseFirestore.instance
        .collection('produitdisponible')
        .where('uid', isEqualTo: widget.commercantId)
        .get();

    setState(() {
      products = allProductsSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'price': doc['price'],
          'imageUrl': doc['imageUrl'],
        };
      }).toList();

      availableProducts = Set.from(availableProductsSnapshot.docs.map((doc) => doc.id));
    });
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
      String favoritePath = 'favorites.${widget.commercantId}';
      if (favorites.contains(productId)) {
        await userDocRef.update({
          favoritePath: FieldValue.arrayRemove([productId]),
        });
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .doc('${widget.commercantId}_$productId')
            .delete();
        setState(() {
          favorites.remove(productId);
        });
      } else {
        await userDocRef.update({
          favoritePath: FieldValue.arrayUnion([productId]),
        });
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .doc('${widget.commercantId}_$productId')
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
      if (quantity > 0 && availableProducts.contains(productId)) {
        OrderItem item = OrderItem(
          name: product['name'],
          quantity: quantity,
          price: double.parse(product['price']), imageUrl: '',
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MethodeDeLivraison(
          orderId: 'exampleOrderId',
          totalAchat: 100.0,
          orderItems: products.map((product) => OrderItem(
            name: product['name'],
            quantity: quantities[product['id']] ?? 0,
            price: double.parse(product['price']), imageUrl: '',
          )).toList(),
          commercantUid: widget.commercantId,
        ),
      ),
    );
  }

  void _handleOrderAndConfirm() {
    _addToCart();
    _confirmOrder();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  var product = products[index];
                  String productId = product['id'];
                  bool isAvailable = availableProducts.contains(productId);

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
                                  if (isAvailable) ...[
                                    IconButton(
                                      icon: Icon(Icons.remove, color: Colors.red),
                                      onPressed: () => _decrementQuantity(productId),
                                    ),
                                    Text('${quantities[productId] ?? 0}'),
                                    IconButton(
                                      icon: Icon(Icons.add, color: Colors.green),
                                      onPressed: () => _incrementQuantity(productId),
                                    ),
                                  ] else ...[
                                    Text('Non disponible', style: TextStyle(color: Colors.red)),
                                  ],
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
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: MyElevatedButton(
                  buttonText: 'Confirmer',
                  onPressed: _handleOrderAndConfirm,
                )
            ),
          ],
        ),
      ),
    );
  }
}

