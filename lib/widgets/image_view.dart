import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:photoarc/utils/file_utils.dart';
import 'package:photoarc/utils/snackbar_utils.dart';
import 'dialog_box.dart';

class ImageView extends StatelessWidget {
  final String assetId;

  const ImageView({
    super.key,
    required this.assetId,
  });

  Future<File?> _getImageFile() async {
    final asset = await AssetEntity.fromId(assetId);
    return asset?.file;
  }

  Future<void> _shareImage(BuildContext context, File file) async {
    try {
      final XFile xFile = XFile(file.path);
      Share.shareXFiles([xFile], text: 'Check out this image!');
    } catch (e) {
      showErrorSnackbar(context, 'Error sharing image: $e');
    }
  }

  Future<void> _editImage(BuildContext context, File file) async {
    try {
      final Uint8List imageBytes = await file.readAsBytes();

      final Uint8List? editedImage = await Navigator.push<Uint8List?>(
        context,
        MaterialPageRoute(
          builder: (context) => ImageEditor(
            image: imageBytes,
          ),
        ),
      );

      if (editedImage != null) {
        // Create a temporary file to save the edited image
        final tempFile = File('${(await getTemporaryDirectory()).path}/edited_${path.basename(file.path)}');
        await tempFile.writeAsBytes(editedImage);

        // Call the download function to save the edited image to a specific location
        await downloadImage(context, tempFile);
      } else {
        showErrorSnackbar(context, 'Editing cancelled or failed.');
      }
    } catch (e) {
      showErrorSnackbar(context, 'Error editing image: $e');
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => DialogBox(
        title: 'Delete Image',
        subtitle: 'Are you sure you want to delete this image?',
        primaryButtonText: 'Delete',
        secondaryButtonText: 'Cancel',
        primaryButtonAction: () => Navigator.of(context).pop(true),
        secondaryButtonAction: () => Navigator.of(context).pop(false),
        primaryColor: Colors.red,
      ),
    );

    if (confirm == true) {
      _deleteImage(context);
    }
  }

  Future<void> _deleteImage(BuildContext context) async {
    try {
      await PhotoManager.editor.deleteWithIds([assetId]);
      showPrimarySnackbar(context, 'Image deleted successfully.');
      Navigator.of(context).pop(true);
    } catch (e) {
      showErrorSnackbar(context, 'Error deleting image: $e');
    }
  }

  void _showImageInfo(BuildContext context, File file) {
    final fileInfo = 'File Name: ${path.basename(file.path)}\n'
        'Size: ${(file.lengthSync() / 1024).toStringAsFixed(2)} KB\n'
        'Last Modified: ${file.lastModifiedSync()}';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Image Info',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                fileInfo,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<File?>(
        future: _getImageFile(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final file = snapshot.data;
          if (file == null) {
            return const Center(child: Text('Image not found', style: TextStyle(color: Colors.white)));
          }

          return Stack(
            children: [
              PhotoView(
                imageProvider: FileImage(file),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 5,
                backgroundDecoration: const BoxDecoration(color: Colors.black),
              ),
              Positioned(
                top: 40,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white, size: 30),
                        onPressed: () => _editImage(context, file),
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        icon: const Icon(Icons.share, color: Colors.white, size: 30),
                        onPressed: () => _shareImage(context, file),
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent, size: 30),
                        onPressed: () => _confirmDelete(context),
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        icon: const Icon(Icons.info, color: Colors.white, size: 30),
                        onPressed: () => _showImageInfo(context, file),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
