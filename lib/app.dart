import 'package:flutter/material.dart';
import 'package:geolocation/controller/location_controller.dart';
import 'package:geolocation/controller_binding.dart';
import 'package:geolocation/routes/routes.dart';
import 'package:geolocation/screen/splash_screen.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: ControllerBinding(),
      getPages: getPages,
      initialRoute: splashScreen,
      home: const SplashScreen(),
    );
  }
}


