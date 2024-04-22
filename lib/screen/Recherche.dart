import 'package:flutter/material.dart';
import 'package:hanout/widget/bottom_navigation_bar.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset('assets/logo.png',
          height: 50,),
      ),
      bottomNavigationBar: MyBottomNavigationBar(
        currentIndex: 1,
        onItemSelected: (index) {
          print("Selected index: $index");
        },
      ),
    );
  }
}
