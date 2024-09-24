import 'package:flutter/material.dart';
import 'package:photoarc/screens/home_screen.dart';

class Routes {
  static const String home = '/home';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomeScreen(),
    };
  }
}