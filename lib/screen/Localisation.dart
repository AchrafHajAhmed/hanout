import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hanout/color.dart';
import 'package:hanout/screen/acceuil.dart';
import 'package:hanout/widget/elevated_button.dart';
import 'package:hanout/widget/map.dart';

class Localisation extends StatefulWidget {
  @override
  _LocalisationState createState() => _LocalisationState();
}

class _LocalisationState extends State<Localisation> {
  final TextEditingController _addressController = TextEditingController();

  void _saveAddress() async {
    String? cityName = await getCityFromUserLocation();
    if (cityName != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Acceuil(cityName: cityName),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de récupérer le nom de la ville. Veuillez réessayer.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter une adresse'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Acceuil(cityName: '')),
              );
            },
            child: Text(
              'Ignorer',
              style: TextStyle(color: AppColors.secondaryColor),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'Entrez votre adresse',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          MyMap(
            height: MediaQuery.of(context).size.height * 3 / 5,
            screenWidth: MediaQuery.of(context).size.width,
            markers: {},
          ),
          SizedBox(height: 20),
          MyElevatedButton(
            buttonText: 'Enregistrer l\'adresse',
            onPressed: _saveAddress,
          ),
        ],
      ),
    );
  }
}

Future<String?> getCityFromUserLocation() async {
  try {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    String cityName = placemarks.first.locality ?? 'Inconnu';
    return cityName;
  } catch (e) {
    print('Error retrieving user location: $e');
    return null;
  }
}




