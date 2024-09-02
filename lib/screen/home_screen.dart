import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController _mapController;
  Position? _position;
  LatLng _currentLocation = const LatLng(0, 0);
  final List<LatLng> _polylineCoordinates = [];

  @override
  void initState() {
    super.initState();
    _locationPermissionHandler(() {
      _locationUpdate();
      _startLocationUpdates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Tracker'),
      ),
      body: GoogleMap(
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
              title: 'Your Current Location',
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
            points: _polylineCoordinates,
            color: Colors.red,
            width: 5, // Adjust the width of the polyline as needed
          ),
        },
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
      ),
    );
  }

  Future<void> _locationUpdate() async {
    _position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
      timeLimit: const Duration(seconds: 10),
    );
    if (_position != null) {
      LatLng newLocation = LatLng(_position!.latitude, _position!.longitude);
      setState(() {
        _currentLocation = newLocation;
        _polylineCoordinates.add(newLocation);
      });
      await _mapController.animateCamera(CameraUpdate.newLatLng(newLocation));
    }
  }

  void _startLocationUpdates() {
    Geolocator.getPositionStream().listen((Position position) {
      LatLng newLocation = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentLocation = newLocation;
        _polylineCoordinates.add(newLocation);
      });
      _mapController.animateCamera(CameraUpdate.newLatLng(newLocation));
    });
  }

  Future<void> _locationPermissionHandler(VoidCallback startService) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      final bool isEnabled = await Geolocator.isLocationServiceEnabled();
      if (isEnabled) {
        startService();
      } else {
        Geolocator.openLocationSettings();
      }
    } else {
      if (permission == LocationPermission.deniedForever) {
        Geolocator.openAppSettings();
        return;
      }
      LocationPermission permissionRequest =
          await Geolocator.requestPermission();
      if (permissionRequest == LocationPermission.always ||
          permissionRequest == LocationPermission.whileInUse) {
        _locationPermissionHandler(startService);
      }
    }
  }
}
