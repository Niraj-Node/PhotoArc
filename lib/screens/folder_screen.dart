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
  static final Map<String, List<AssetEntity>> _cachedAssets = {};
  List<AssetEntity> assets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    final folderId = widget.folder.id;

    // Check if assets for this folder are already cached
    if (_cachedAssets.containsKey(folderId)) {
      assets = _cachedAssets[folderId]!;
      setState(() {
        _isLoading = false;
      });
    } else {
      await _fetchAssets(); // Fetch assets if not cached
    }
  }

  Future<void> _fetchAssets() async {
    final folderId = widget.folder.id;

    assets = await widget.folder.getAssetListRange(start: 0, end: 100000); // Fetch all assets
    _cachedAssets[folderId] = assets; // Cache the result

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.name),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: assets.length,
        itemBuilder: (_, index) {
          return AssetThumbnail(asset: assets[index]);
        },
      ),
    );
  }
}
