import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photoarc/widgets/folder_card.dart';

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
    // Define the main folders you want to separate (like Camera and Screenshots)
    final List<String> mainFolderNames = ['Camera', 'Screenshots', 'Recent', 'Download'];

    // Separate the main folders and other folders
    final mainFolders = folders.where((folder) => mainFolderNames.contains(folder.name)).toList();
    final otherFolders = folders.where((folder) => !mainFolderNames.contains(folder.name)).toList();

    return ListView(
      children: [
        // Section for Main Folders
        if (mainFolders.isNotEmpty) ...[
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // Prevent nested scrolling issues
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1,
            ),
            itemCount: mainFolders.length,
            itemBuilder: (context, index) {
              final folder = mainFolders[index];
              return FolderCard(
                folder: folder,
                onTap: () => onFolderTap(folder),
              );
            },
          ),
        ],

        // Section for Other Folders
        if (otherFolders.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            child: Text(
              'Other Folders',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1,
            ),
            itemCount: otherFolders.length,
            itemBuilder: (context, index) {
              final folder = otherFolders[index];
              return FolderCard(
                folder: folder,
                onTap: () => onFolderTap(folder),
              );
            },
          ),
        ],
      ],
    );
  }
}
