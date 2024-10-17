import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photoarc/widgets/images/local_images/folder_card.dart';

class FolderGrid extends StatelessWidget {
  final List<AssetPathEntity> folders;
  final Function(AssetPathEntity) onFolderTap;

  const FolderGrid({
    Key? key,
    required this.folders,
    required this.onFolderTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> mainFolderNames = ['Camera', 'Screenshots', 'Recent', 'Download'];
    final mainFolders = folders.where((folder) => mainFolderNames.contains(folder.name)).toList();
    final otherFolders = folders.where((folder) => !mainFolderNames.contains(folder.name)).toList();

    return SingleChildScrollView(  // Scrollable container to prevent overflow
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mainFolders.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Text('Main Folders',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            _buildGrid(context, mainFolders),
          ],
          if (otherFolders.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Text('Other Folders',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            _buildGrid(context, otherFolders),
          ],
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<AssetPathEntity> folders) {
    return GridView.builder(
      shrinkWrap: true,  // Allows GridView to shrink to its content size
      physics: const NeverScrollableScrollPhysics(),  // Disable GridView scrolling
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1,
      ),
      itemCount: folders.length,
      itemBuilder: (context, index) {
        final folder = folders[index];
        return FolderCard(
          folder: folder,
          onTap: () => onFolderTap(folder),
        );
      },
    );
  }
}
