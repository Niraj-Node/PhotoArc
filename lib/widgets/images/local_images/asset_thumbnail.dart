import 'dart:typed_data'; // Import for Uint8List
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class AssetThumbnail extends StatelessWidget {
  final AssetEntity asset;
  final bool isSelected;
  final VoidCallback? onTap; // Callback for tap
  final VoidCallback? onLongPress; // Callback for long press

  const AssetThumbnail({
    super.key,
    required this.asset,
    this.isSelected = false, // Default to not selected
    this.onTap, // Optional tap callback
    this.onLongPress, // Optional long press callback
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailData,
      builder: (_, snapshot) {
        final bytes = snapshot.data;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || bytes == null) {
          return const Center(child: Text('Error loading thumbnail'));
        }

        return InkWell(
          onTap: onTap, // Use the onTap callback
          onLongPress: onLongPress, // Use the onLongPress callback
          child: Stack(
            children: [
              Positioned.fill(
                child: ColorFiltered(
                  colorFilter: isSelected
                      ? ColorFilter.mode(Colors.blue.withOpacity(0.5), BlendMode.srcATop)
                      : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                  child: Image.memory(
                    bytes,
                    fit: BoxFit.cover,
                  ),
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
              if (isSelected)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
