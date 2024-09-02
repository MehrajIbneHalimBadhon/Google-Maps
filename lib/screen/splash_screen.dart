import 'package:flutter/material.dart';
import 'package:geolocation/routes/routes.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../app.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    _moveToNextScreen();
    super.initState();
  }
  Future<void> _moveToNextScreen() async {
    await Future.delayed(Duration(seconds: 2));
    Get.offAllNamed(homeScreen);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset('assets/images/Animation - 1725026349571.json'),
      ),
    );
  }
}
