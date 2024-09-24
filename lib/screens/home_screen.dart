import 'package:flutter/material.dart';
import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'package:photoarc/utils/routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

// WidgetsBindingObserver is Interface for classes that register with the Widgets layer binding.
class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _requestPermission(); // Request permission when the page loads
  }

  Future<void> _requestPermission() async {
    // If permission is not granted, PhotoManager.requestPermissionExtend() prompts the user to grant permission.
    // If permission is already granted, PhotoManager.requestPermissionExtend() returns the current permission status without prompting the user again.
    PermissionState storagePermission = await PhotoManager.requestPermissionExtend();

    if (storagePermission.isAuth) {
      // If permission is granted, the addPostFrameCallback ensures that the navigation
      // only happens after the current widget is fully rendered and displayed on the screen.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(Routes.gallery);
      });
    } else {
      // Show a dialog or Snackbar if permission is denied
      _showPermissionDeniedDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      // Disable dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Access Required',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
              'To access and display your photos, we need permission to your storage. Without this, the app will not function as intended.\n\n'
                  'Would you like to grant access or open settings to change the permissions?'
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Close the app on cancel
                exit(0);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                // Open device settings for the app if the user chooses
                Navigator.of(context).pop();
                PhotoManager.openSetting();
                Future.delayed(const Duration(milliseconds: 100), () {
                  exit(0);
                });
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
    // No UI is rendered as everything is permission-based navigation
    return const SizedBox.shrink();
  }
}