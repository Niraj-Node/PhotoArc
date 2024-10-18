import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageCard extends StatelessWidget {
  final String imageUrl;
  final DateTime uploadTime;
  final bool isSelected;
  final Function() onTap;
  final Function() onLongPress;

  const ImageCard({
    super.key,
    required this.imageUrl,
    required this.uploadTime,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    String formattedDate = "${uploadTime.day}/${uploadTime.month}/${uploadTime.year}";

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Stack(
          children: [
            Opacity(
              opacity: isSelected ? 0.5 : 1.0,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            if (isSelected)
              Positioned(
                right: 3,
                top: 3,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (_) {},
                  activeColor: Colors.blueAccent,
                ),
              ),
            Positioned(
              bottom: 5,
              left: 5,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text(
                  formattedDate,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
