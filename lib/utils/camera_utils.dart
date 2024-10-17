import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import 'package:photoarc/widgets/snackbar/primary_snackbar.dart';
import 'package:photoarc/widgets/snackbar/error_snackbar.dart';

// Show success snackbar
void showPrimarySnackbar(BuildContext context, String message) {
  primarySnackbar(context, message);
}

// Show error snackbar
void showErrorSnackbar(BuildContext context, String message) {
  ErrorSnackbar(context, message);
}

// Share the image
void shareImage(BuildContext context, File? imageFile) {
  if (imageFile != null) {
    final XFile xFile = XFile(imageFile.path);
    Share.shareXFiles([xFile], text: 'Check out this image!');
  } else {
    showErrorSnackbar(context, 'No image to share.');
  }
}

// Download the image to the local storage
Future<void> downloadImage(BuildContext context, File? imageFile) async {
  if (imageFile != null) {
    try {
      // Get the external storage directory for Download folder
      final directory = Directory('/storage/emulated/0/Download/Photoarc');

      if (!await directory.exists()) {
        await directory.create(recursive: true); // Create directory if not exists
      }

      final imageName = path.basename(imageFile.path);
      final savePath = path.join(directory.path, imageName);
      final File newImage = await imageFile.copy(savePath);

      showPrimarySnackbar(context, 'Image saved to: Download/Photoarc');
    } catch (e) {
      print(e);
      showErrorSnackbar(context, 'Error downloading image: $e');
    }
  } else {
    showErrorSnackbar(context, 'No image to download.');
  }
}
