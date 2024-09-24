import 'package:flutter/material.dart';
import 'package:photoarc/screens/home_screen.dart';
import 'package:photoarc/screens/signin_screen.dart';
import 'package:photoarc/screens/signup_screen.dart';
import 'package:photoarc/screens/gallery_screen.dart';
import 'package:photoarc/screens/camera_screen.dart';

class Routes {
  static const String home = '/home';
  static const String signin = '/signin';
  static const String signup = '/signup';
  static const String gallery = '/gallery';
  static const String camera = '/camera';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomeScreen(),
      signin: (context) => const SignInScreen(),
      signup: (context) => const SignUpScreen(),
      gallery: (context) => const GalleryScreen(),
      camera: (context) => const CameraScreen(),
    };
  }
}
