import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photoarc/widgets/images/local_images/asset_thumbnail.dart';

class FolderCard extends StatelessWidget {
  final AssetPathEntity folder;
  final VoidCallback onTap;

  const FolderCard({
    Key? key,
    required this.folder,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AssetEntity>>(
      future: folder.getAssetListRange(start: 0, end: 1),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final recentAsset = snapshot.data!.first;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AssetThumbnail(asset: recentAsset, onTap: onTap),
                  ),
                  _buildGradient(),
                  _buildFolderInfo(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGradient() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.transparent,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
      ),
    );
  }

  Widget _buildFolderInfo(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              folder.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4.0),
            FutureBuilder<int>(
              future: folder.assetCountAsync,
              builder: (context, snapshot) {
                return Text(
                  '${snapshot.data ?? 0} items',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12.0,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
