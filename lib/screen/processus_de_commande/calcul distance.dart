import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class DistanceCalculator {
  final double userLatitude;
  final double userLongitude;
  List<Map<String, dynamic>> marchands = [];

  DistanceCalculator({required this.userLatitude, required this.userLongitude});

  Future<void> getMarchandsFromFirestore() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('commercants').get();
    marchands = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'latitude': data['latitude'],
        'longitude': data['longitude'],
        'name': data['name'],
      };
    }).toList();
  }

  double calculateDistance(double merchantLatitude, double merchantLongitude) {
    return Geolocator.distanceBetween(userLatitude, userLongitude, merchantLatitude, merchantLongitude) / 1000;
  }

  double calculateCost(double distance) {
    return distance * 1.5;
  }

  void calculateAndPrintAllDistances() {
    for (var marchand in marchands) {
      double distance = calculateDistance(marchand['latitude'], marchand['longitude']);
      double cost = calculateCost(distance);
      print('Distance to ${marchand['name']}: $distance km, Cost: $cost');
    }
  }
}
