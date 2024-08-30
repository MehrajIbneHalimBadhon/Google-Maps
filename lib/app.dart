import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocation/splash_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
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
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {_locationPermissionHandler(() async {
    // Get initial position and update map
    Position initialPosition = await Geolocator.getCurrentPosition();
    _locationUpdate(initialPosition);

    // Start listening to position stream
    _positionStream = Geolocator.getPositionStream().listen((position) {
      setState(() {
        _locationUpdate(position);
      });
    });
  });
  super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoLocator'),
      ),
      body: GoogleMap(

        myLocationEnabled: true,
          myLocationButtonEnabled: true,
          mapType: MapType.hybrid,
          initialCameraPosition:
              CameraPosition(target: _currentLocation, zoom: 15),
          markers: <Marker>{
            Marker(
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
                polylineId: const PolylineId('Route'),
                points: _polylineCoordinates,
                color: Colors.red)
          },
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          }),
    );
  }

  Future<void> _locationUpdate(Position position) async {
    LatLng newLocation = LatLng(position.latitude, position.longitude);
    setState(() {
      _position = position;
      _currentLocation = newLocation;
      _polylineCoordinates.add(newLocation);
    });
    try {
      await _mapController.animateCamera(CameraUpdate.newLatLng(newLocation));
    } catch (e) {
      print('Error animating camera: $e');}
  }


  Future<void> _locationPermissionHandler(VoidCallback startService) async {
    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      // Permission granted
      final bool isEnabled = await Geolocator.isLocationServiceEnabled();
      if (isEnabled) {
        //start the provided location service
        startService();
      } else {
        // Turn on GPS service
        Geolocator.openLocationSettings();
      }
    } else {
      // Permission denied
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
