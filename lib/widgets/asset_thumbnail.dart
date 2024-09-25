import 'dart:typed_data'; // Import for Uint8List
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '/widgets/image_view.dart';
import '/widgets/video_view.dart';

class AssetThumbnail extends StatelessWidget {
  final AssetEntity asset;
  final VoidCallback? onTapCallback; // Optional callback

  const AssetThumbnail({
    super.key,
    required this.asset,
    this.onTapCallback, // Optional callback parameter
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailData,
      builder: (_, snapshot) {
        final bytes = snapshot.data;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        else if (snapshot.hasError || bytes == null) {
          return const Center(child: Text('Error loading thumbnail'));
        }

        // Wrap the thumbnail in an InkWell to make it tappable
        return InkWell(
          onTap: () {
            if (onTapCallback != null) {
              onTapCallback!();
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    if (asset.type == AssetType.image) {
                      return ImageView(imageFile: asset.file);
                    } else {
                      return VideoView(videoFile: asset.file);
                    }
                  },
                ),
              );
            }
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.memory(
                  bytes,
                  fit: BoxFit.cover,
                ),
              ),
              if (asset.type == AssetType.video)
                Center(
                  child: Container(
                    color: Colors.black45,
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
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
