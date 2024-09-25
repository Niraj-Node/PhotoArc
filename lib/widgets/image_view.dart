import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageView extends StatelessWidget {
  const ImageView({
    Key? key,
    required this.imageFile,
  }) : super(key: key);

  final Future<File?> imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background for better image viewing
      body: FutureBuilder<File>(
        future: imageFile.then((value) => value!),
        builder: (_, snapshot) {
          final file = snapshot.data;
          if (file == null) return const Center(child: CircularProgressIndicator());

          return Stack(
            children: [
              PhotoView(
                imageProvider: FileImage(file),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 5,
                backgroundDecoration: const BoxDecoration(
                  color: Colors.black, // Dark background for image view
                ),
                heroAttributes: const PhotoViewHeroAttributes(tag: 'imageHero'),
              ),
              Positioned(
                top: 40,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
