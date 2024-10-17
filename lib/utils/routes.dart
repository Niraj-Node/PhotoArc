import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photoarc/screens/home_screen.dart';
import 'package:photoarc/screens/signin_screen.dart';
import 'package:photoarc/screens/signup_screen.dart';
import 'package:photoarc/screens/gallery_screen.dart';
import 'package:photoarc/screens/camera_screen.dart';
import 'package:photoarc/screens/folder_screen.dart';
import 'package:photoarc/screens/cloud_images_screen.dart';

class Routes {
  static const String home = '/home';
  static const String signin = '/signin';
  static const String signup = '/signup';
  static const String gallery = '/gallery';
  static const String camera = '/camera';
  static const String folder = '/folder';
  static const String cloudImages = '/cloudImages';

  // Map of routes and their corresponding widget builders
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const PermissionScreen(),
      signin: (context) => const SignInScreen(),
      signup: (context) => const SignUpScreen(),
      gallery: (context) => const GalleryScreen(),
      camera: (context) => const CameraScreen(),
      folder: (context) {
        final folder = ModalRoute.of(context)!.settings.arguments as AssetPathEntity;
        return FolderScreen(folder: folder);
        // This means that when the user navigates to the /folder route,
        // they will see the FolderScreen with details of the selected folder displayed.
      },
      cloudImages: (context) => const CloudImagesScreen(),
    };
  }
}
