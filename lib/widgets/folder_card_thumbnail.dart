import 'dart:typed_data'; // Import for Uint8List
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class CardThumbnail extends StatelessWidget {
  final AssetEntity asset;
  final VoidCallback onTapCallback;

  const CardThumbnail({
    Key? key,
    required this.asset,
    required this.onTapCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(ThumbnailSize(200, 200)), // Fetch thumbnail data
      builder: (context, snapshot) {
        final thumbData = snapshot.data;

        if (thumbData == null) {
          return const Center(child: CircularProgressIndicator()); // Show loading indicator while thumbnail is loading
        }

        return GestureDetector(
          onTap: onTapCallback, // Execute the callback when the thumbnail is pressed
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.memory(
                  thumbData,
                  fit: BoxFit.cover, // Display the image thumbnail covering the available space
                ),
              ),
              if (asset.type == AssetType.video)
                Center(
                  child: Container(
                    color: Colors.black45,
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 40.0,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
