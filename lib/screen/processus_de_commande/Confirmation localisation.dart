import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hanout/screen/processus_de_commande/calcul distance.dart';
import 'package:hanout/widget/Map.dart';
import 'package:hanout/widget/elevated_button.dart';

class ConfirmationLocalisation extends StatefulWidget {
  @override
  _ConfirmationLocalisationState createState() => _ConfirmationLocalisationState();
}

class _ConfirmationLocalisationState extends State<ConfirmationLocalisation> {
  DistanceCalculator? _distanceCalculator;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  void _determinePosition() async {
    Position currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _distanceCalculator = DistanceCalculator(userLatitude: currentPosition.latitude, userLongitude: currentPosition.longitude);
      _initializeMerchantDistanceCalculations();
    });
  }

  void _initializeMerchantDistanceCalculations() async {
    await _distanceCalculator!.getMarchandsFromFirestore();
    _distanceCalculator!.calculateAndPrintAllDistances();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true,
        title: Image.asset(
          'assets/logo.png',
          height: 50,
        ),),
      body: Column(
        children: [
          if (_isLoading)
            Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Column(
              children: [
                Text('Confirmation Address',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w900,
                    fontSize: 28.0,
                  ),),
                SizedBox(height: 20,),
                TextField(),
                SizedBox(height: 5,),
                Map(height: MediaQuery.of(context).size.height * 3 / 5,  screenWidth: MediaQuery.of(context).size.width),
              ],
            ),
        ],
      ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    floatingActionButton: Padding(
    padding: const EdgeInsets.all(40.0),
    child:MyElevatedButton(buttonText: 'Confirm', onPressed:  () {
        if (_distanceCalculator != null) {
          double deliveryCost = _distanceCalculator!.calculateCost(
              _distanceCalculator!.calculateDistance(
                _distanceCalculator!.marchands[0]['latitude'],
                _distanceCalculator!.marchands[0]['longitude'],
              )
          );
          Navigator.pop(context, deliveryCost);
        }
      },
      ),)
    );
  }
}

