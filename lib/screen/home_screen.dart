import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controller/location_controller.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  LatLng _currentLocation = const LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    Get.find<LocationController>().locationPermissionHandler(() {
      _updateLocation();
      _startLocationUpdates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Tracker'),
      ),
      body: GetBuilder<LocationController>(
        builder: (locationController) {
          return locationController.position != null
              ? GoogleMap(
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.hybrid,
            initialCameraPosition:
            CameraPosition(target: _currentLocation, zoom: 12),
            markers: <Marker>{
              Marker(
                visible: true,
                draggable: true,
                markerId: const MarkerId('Current Location'),
                position: _currentLocation,
                infoWindow: InfoWindow(
                  title: 'My Current Location',
                  snippet:
                  '${_currentLocation.latitude}, ${_currentLocation.longitude}',
                ),
              ),
            },
            polylines: <Polyline>{
              Polyline(
                visible: true,
                jointType: JointType.mitered,
                polylineId: const PolylineId('Route'),
                points: locationController.polylineCoordinates,
                color: Colors.red,
                width: 5,
              ),
            },
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
          )
              : const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<void> _updateLocation() async {
    final LocationController locationController = Get.find<LocationController>();
    locationController.position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
      timeLimit: const Duration(seconds: 10),
    );

    if (locationController.position != null) {
      LatLng newLocation = LatLng(locationController.position!.latitude,
          locationController.position!.longitude);
      setState(() {
        _currentLocation = newLocation;
        locationController.polylineCoordinates.add(newLocation);
      });
      if (_mapController != null) {
        await _mapController!.animateCamera(CameraUpdate.newLatLng(newLocation));
      }
    }
  }

  void _startLocationUpdates() {
    Geolocator.getPositionStream().listen((Position position) {
      LatLng newLocation = LatLng(position.latitude, position.longitude);
      final LocationController locationController = Get.find<LocationController>();
      setState(() {
        _currentLocation = newLocation;
        locationController.polylineCoordinates.add(newLocation);
      });
      if (_mapController != null) {
        _mapController!.animateCamera(CameraUpdate.newLatLng(newLocation));
      }
    });
  }
}
