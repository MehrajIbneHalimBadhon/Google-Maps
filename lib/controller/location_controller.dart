import 'dart:ui';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationController extends GetxController {
  Position? position;
  bool isSuccess = false;
  List<LatLng> polylineCoordinates = [];

  Future<void> locationPermissionHandler(VoidCallback startService) async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      final bool isEnabled = await Geolocator.isLocationServiceEnabled();
      if (isEnabled) {
        startService();
      } else {
        await Geolocator.openLocationSettings();
        // Optionally re-check if the location service is enabled after opening settings
        if (await Geolocator.isLocationServiceEnabled()) {
          startService();
        }
      }
    } else {
      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        return;
      }
      LocationPermission permissionRequest = await Geolocator.requestPermission();
      if (permissionRequest == LocationPermission.always ||
          permissionRequest == LocationPermission.whileInUse) {
        // Call handler again to re-check the permission status
        locationPermissionHandler(startService);
      }
    }
  }
}
