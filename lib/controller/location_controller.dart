

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationController extends GetxController {
  Position? position;
  bool isSuccess = false;
  List<LatLng> polylineCoOrdinates = [];
  Future<void> currentLocation() async {
    LocationPermission locationPermission = await Geolocator.checkPermission();

    if (locationPermission == LocationPermission.denied ||
        locationPermission == LocationPermission.deniedForever) {
      // Request permission if it's denied
      locationPermission = await Geolocator.requestPermission();
    }

    if (locationPermission == LocationPermission.always ||
        locationPermission == LocationPermission.whileInUse) {
      final bool isLocationServiceEnabled =
      await Geolocator.isLocationServiceEnabled();
      if (isLocationServiceEnabled) {
        position = await Geolocator.getCurrentPosition();

        isSuccess = true;
        update();
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.bestForNavigation,
              timeLimit: Duration(seconds: 10)),
        ).listen((lastPosition) {
          print(position.toString());
          position = lastPosition;
          polylineCoOrdinates.add(LatLng(lastPosition.latitude, lastPosition.longitude));
          update();
        });
      } else {
        // Handle the case where location services are disabled
        currentLocation();
      }
    } else if (locationPermission == LocationPermission.deniedForever) {
      // If the permission is still deniedForever, take the user to settings
      Geolocator.openAppSettings();
    }
  }
}