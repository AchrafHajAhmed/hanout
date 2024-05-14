import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class DistanceCalculator {
  double userLatitude = 0.0;
  double userLongitude = 0.0;
  List<Map<String, dynamic>> marchands = [];

  DistanceCalculator({required this.userLatitude, required this.userLongitude});

  double calculateDistance(double merchantLatitude, double merchantLongitude) {
    const earthRadius = 6371000;

    double lat1 = userLatitude * pi / 180;
    double lon1 = userLongitude * pi / 180;
    double lat2 = merchantLatitude * pi / 180;
    double lon2 = merchantLongitude * pi / 180;

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = earthRadius * c;
    return distance;
  }

  double calculateCost(double distance) {
    double costPerMeter = 0.010;
    double cost = distance * costPerMeter;
    return cost;
  }

  Future<void> getMarchandsFromFirestore() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('commercants').get();
    marchands = snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return {'latitude': data['latitude'], 'longitude': data['longitude']};
    }).toList();
  }

  void calculateAndPrintAllDistances() {
    for (var merchant in marchands) {
      double distance = calculateDistance(merchant['latitude'], merchant['longitude']);
      double cost = calculateCost(distance);
      print('Distance jusqu\'au commerçant: $distance meters');
      print('Cost to reach merchant: $cost dinar');
    }
  }
}
