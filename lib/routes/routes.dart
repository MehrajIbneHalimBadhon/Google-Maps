import 'package:geolocation/screen/home_screen.dart';
import 'package:get/get.dart';

import '../screen/splash_screen.dart';

const String splashScreen = '/splash-screen';
const String homeScreen = '/home-screen';
List<GetPage> getPages =[
  GetPage(
    name: splashScreen,
    page: () => const SplashScreen(),
  ),
  GetPage(
    name: homeScreen,
    page: () => const HomeScreen(),
  ),
];