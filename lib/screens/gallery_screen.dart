import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photoarc/utils/routes.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {

  @override
  void initState() {
    super.initState();
  }

  Future<void> _handleCameraAction(BuildContext context) async {
    final cameraStatus = await Permission.camera.status;

    if (!cameraStatus.isGranted) {
      final result = await Permission.camera.request();
      if (!result.isGranted) {
        _showPermissionDeniedDialog();
        return;
      }
    }

    // If the camera permission is granted, navigate to the CameraScreen
    Navigator.of(context).pushNamed(Routes.camera);
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Camera Permission Required'),
          content: const Text(
            'We need access to your camera to take pictures. Please grant camera permission.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                openAppSettings(); // Open app settings for the user to change permissions
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt, size: 30),
            onPressed: () => _handleCameraAction(context),
          ),
        ],
      ),
    );
  }
}
