import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import 'package:photoarc/utils/snackbar_utils.dart';

// Helper function to get the file size in a readable format
String getFileSize(File file) {
  final bytes = file.lengthSync();
  if (bytes <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB"];
  final i = (bytes.toString().length - 1) ~/ 3;
  final size = (bytes / (1 << (10 * i))).toStringAsFixed(2);
  return '$size ${suffixes[i]}';
}

// Helper function to get the date the file was last modified in AM/PM format
String getFormattedDate(File file) {
  final lastModified = file.lastModifiedSync();
  return DateFormat('yyyy-MM-dd ~ hh:mm a').format(lastModified);
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
