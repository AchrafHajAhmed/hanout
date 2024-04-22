import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MySearchBar extends StatefulWidget {
  const MySearchBar({super.key});

  @override
  State<MySearchBar> createState() => _MySearchBarState();
}

class _MySearchBarState extends State<MySearchBar> {
  final TextEditingController _searchController = TextEditingController();
  Future<QuerySnapshot>? _queryResults;


  void _MySearch(String query) {
  if (query.isNotEmpty) {

  _queryResults = FirebaseFirestore.instance
      .collection('categories')
      .where('name', isGreaterThanOrEqualTo: query)
      .where('name', isLessThanOrEqualTo: query + '\uf8ff')
      .get();
  } else {
  _queryResults = Future.value();
  }
  setState(() {});
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(),
    body: Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Recherche produits , superettes , commercants',
              suffixIcon: Icon(Icons.search),
            ),
            onChanged: _MySearch,
          ),
        ),
        Expanded(
          child: FutureBuilder<QuerySnapshot>(
            future: _queryResults,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return CircularProgressIndicator();
              if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                return Text("No results found.");
              }
              return ListView(
                children: snapshot.data!.docs.map((doc) {
                  return ListTile(
                    title: Text(doc.get('name')),
                  );
                }).toList(),
              );
              },
          ),
        ),
      ],
    ),
  );
  }
}