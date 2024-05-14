import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hanout/color.dart';


class AjouterProduit extends StatefulWidget {
  @override
  _AjouterProduitState createState() => _AjouterProduitState();
}

class _AjouterProduitState extends State<AjouterProduit> {
  final CollectionReference products =
  FirebaseFirestore.instance.collection('produit');
  bool isLoading = false;
  String selectedCategory = 'Toutes';

  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  void fetchCategories() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('categories').get();
    setState(() {
      categories = ['Toutes', ...querySnapshot.docs.map((doc) => (doc.data() as Map<String, dynamic>?)?['name'] ?? '').toList()];
    });
  }



  void updateProductAvailability(String documentId, bool newAvailability) {
    products.doc(documentId).update({'available': newAvailability});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset('assets/logo.png', height: 50),
      ),
      body: Column(
        children: [
          _buildTopBar(context),
          _buildCategoryFilter(),
          Expanded(
            child: _buildProductList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      height: 69,
      color: AppColors.primaryColor,
      child: Row(
        children: [
          SvgPicture.asset('assets/Market.svg', height: 60),
          SizedBox(width: 10),
          Text(
            'Paramètre',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 24.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ChoiceChip(
              label: Text(categories[index]),
              selected: selectedCategory == categories[index],
              onSelected: (selected) {
                setState(() {
                  selectedCategory = categories[index];
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductList() {
    return StreamBuilder(
      stream: selectedCategory == 'Toutes'
          ? products.snapshots()
          : products.where('categories', isEqualTo: selectedCategory).snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.data?.docs.isEmpty ?? true) {
          return Center(child: Text('No products found'));
        }
        return ListView.separated(
          itemCount: snapshot.data!.docs.length,
          separatorBuilder: (context, index) => Divider(color: Colors.grey),
          itemBuilder: (context, index) {
            DocumentSnapshot document = snapshot.data!.docs[index];
            return _buildProductItem(document);
          },
        );
      },
    );
  }

  Widget _buildProductItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    bool isAvailable = data['available'] as bool? ?? false;
    return ListTile(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _productDetails(data),
          _productImageWithAvailability(data, isAvailable, document.id),
        ],
      ),
    );
  }

  Widget _productDetails(Map<String, dynamic> data) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(data['name'], style: TextStyle(fontWeight: FontWeight.bold)),
          Text(data['description']),
          Text('${data['price']} Dinar'),
        ],
      ),
    );
  }

  Widget _productImageWithAvailability(Map<String, dynamic> data, bool isAvailable, String documentId) {
    return Column(
      children: [
        CachedNetworkImage(
          imageUrl: data['imageUrl'],
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
          width: 84,
          height: 84,
        ),
        DropdownButton<bool>(
          isExpanded: false,
          value: isAvailable,
          onChanged: (bool? newValue) {
            if (newValue != null) {
              updateProductAvailability(documentId, newValue);
            }
          },
          items: <bool>[true, false].map<DropdownMenuItem<bool>>((bool value) {
            return DropdownMenuItem<bool>(
              value: value,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  value ? 'Disponible' : 'Non disponible',
                  style: TextStyle(color: value ? Colors.green : Colors.red, fontSize: 11),
                ),
              ),
            );
          }).toList(),
          underline: Container(
            height: 0,
            color: Colors.transparent,
          ),
        ),
      ],
    );
  }
}
