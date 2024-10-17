import 'package:flutter/material.dart';
import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'package:photoarc/utils/routes.dart';
import 'package:photoarc/widgets/dialog_box.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  _PermissionScreenState createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  @override
  void initState() {
    super.initState();
    _requestPermission(); // Request permission when the page loads
  }

  Future<void> _requestPermission() async {
    PermissionState storagePermission = await PhotoManager.requestPermissionExtend();

    if (storagePermission.isAuth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(Routes.gallery);
      });
    } else {
      _showPermissionDeniedDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return DialogBox(
          title: 'Access Required',
          subtitle: 'To display your photos, we need access to your photos & videos. Without this, the app will not function as intended.\n\nWould you like to grant access or open settings to change the permissions?',
          primaryButtonText: 'Open Settings',
          secondaryButtonText: 'Cancel',
          primaryButtonAction: () {
            Navigator.of(context).pop();
            PhotoManager.openSetting();
            Future.delayed(const Duration(milliseconds: 100), () {
              exit(0);
            });
          },
          secondaryButtonAction: () {
            exit(0);
          },
          accentColor: Colors.red,
          invertSecondaryButton: true,
          borderRadius: 15.0,
          avatarRadius: 25.0,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
