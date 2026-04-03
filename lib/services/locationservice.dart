
import 'package:geolocator/geolocator.dart';

class LocationService {
 
  Future<Position> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services disabled");
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Permission permanently denied");
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

 
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(
      startLat,
      startLng,
      endLat,
      endLng,
    );
  }

  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return "${distanceInMeters.toStringAsFixed(0)} m";
    } else {
      double km = distanceInMeters / 1000;
      return "${km.toStringAsFixed(2)} km";
    }
  }

  
 
String estimateTravelTimeByMode(double distanceInMeters, String mode) {
  double speedKmPerHour;

  if (mode == "car") {
    speedKmPerHour = 50;
  } else {
    speedKmPerHour = 5;
  }

  double distanceKm = distanceInMeters / 1000;
  double timeInHours = distanceKm / speedKmPerHour;
  double timeInMinutes = timeInHours * 60;

  if (timeInMinutes < 1) {
    return "Less than a minute";
  }

  return "${timeInMinutes.toStringAsFixed(0)} min";
}
}