import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hanout/color.dart';
import 'package:hanout/Commercants/Confirmation_produit.dart';
import 'package:hanout/widget/elevated_button.dart';

class AjouterProduit extends StatefulWidget {
  @override
  _AjouterProduitState createState() => _AjouterProduitState();
}

class _AjouterProduitState extends State<AjouterProduit> {
  final CollectionReference products = FirebaseFirestore.instance.collection('produit');
  bool isLoading = false;
  String selectedCategory = 'Toutes';
  String selectedSubCategory = 'Toutes';
  String searchQuery = '';

  List<String> categories = [];
  List<String> subCategories = [];
  Map<String, bool> modifiedProducts = {};

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  void fetchCategories() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('categories').get();
    setState(() {
      categories = ['Toutes', ...querySnapshot.docs.map((doc) => (doc.data() as Map<String, dynamic>)['name']).toList()];
    });
  }

  void fetchSubCategories(String category) async {
    if (category == 'Toutes') {
      setState(() {
        subCategories = ['Toutes'];
        selectedSubCategory = 'Toutes';
      });
      return;
    }
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('subcategories').where('category', isEqualTo: category).get();
    setState(() {
      subCategories = ['Toutes', ...querySnapshot.docs.map((doc) => (doc.data() as Map<String, dynamic>)['name']).toList()];
      selectedSubCategory = 'Toutes';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child:
        Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset('assets/logo.png', height: 50),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTopBar(context),
          _buildCategoryFilter(),
          _buildSubCategoryFilter(),
          Expanded(
            child: _buildProductList(),
          ),
       MyElevatedButton(
            buttonText: 'Confirmer',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ConfirmModifications(modifiedProducts: modifiedProducts)),
              );
              setState(() {
                modifiedProducts.clear();
              });
            },
          ),
          SizedBox(height: 10,)
        ],
      ),
    ));}
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Rechercher un produit',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
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
            'Ajouter Produit',
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
                  fetchSubCategories(selectedCategory);
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubCategoryFilter() {
    return Container(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: subCategories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ChoiceChip(
              label: Text(subCategories[index]),
              selected: selectedSubCategory == subCategories[index],
              onSelected: (selected) {
                setState(() {
                  selectedSubCategory = subCategories[index];
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductList() {
    Query query = products;

    if (selectedCategory != 'Toutes') {
      query = query.where('category', isEqualTo: selectedCategory);
    }

    if (selectedSubCategory != 'Toutes') {
      query = query.where('subcategory', isEqualTo: selectedSubCategory);
    }

    if (searchQuery.isNotEmpty) {
      query = query.where('name', isGreaterThanOrEqualTo: searchQuery).where('name', isLessThanOrEqualTo: searchQuery + '\uf8ff');
    }

    return StreamBuilder(
      stream: query.snapshots(),
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
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    bool isAvailable = modifiedProducts[document.id] ?? data['available'] as bool? ?? false;
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
              setState(() {
                modifiedProducts[documentId] = newValue;
              });
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
