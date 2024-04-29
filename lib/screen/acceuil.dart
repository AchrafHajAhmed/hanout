import 'package:flutter/material.dart';
import 'package:hanout/screen/processus_de_commande/Panier.dart';
import 'package:hanout/widget/bottom_navigation_bar.dart';
import 'package:hanout/widget/map.dart';

class Acceuil extends StatefulWidget {
  final String cityName;

  const Acceuil({Key? key, this.cityName = ''}) : super(key: key);

  @override
  _AcceuilState createState() => _AcceuilState();
}

class _AcceuilState extends State<Acceuil> {
  late String _cityName;
  late double screenWidth;

  @override
  void initState() {
    super.initState();
    _cityName = widget.cityName;
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
                ]
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
                          )
                      )
                    ]
                )
            ),

            Map(height: 200, screenWidth: MediaQuery.of(context).size.width),

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




