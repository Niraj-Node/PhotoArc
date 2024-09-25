import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photoarc/widgets/asset_thumbnail.dart';

class FolderScreen extends StatefulWidget {
  final AssetPathEntity folder; // Receive the folder as a parameter

  const FolderScreen({super.key, required this.folder});

  @override
  _FolderScreenState createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  List<AssetEntity> assets = [];

  @override
  void initState() {
    super.initState();
    _fetchAssets(); // Fetch assets when the widget is initialized
  }

  Future<void> _fetchAssets() async {
    // Fetch assets from the selected folder
    assets = await widget.folder.getAssetListRange(
      start: 0,
      end: 100000, // Adjust the end value based on your needs
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.name),
      ),
      body: assets.isEmpty
          ? const Center(child: CircularProgressIndicator()) // Show a loading indicator while fetching
          : GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: assets.length,
        itemBuilder: (_, index) {
          return AssetThumbnail(
            asset: assets[index],
          );
        },
      ),
    );
  }
}
