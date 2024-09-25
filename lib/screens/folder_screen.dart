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
  int currentPage = 0;
  bool _isLoading = true;
  bool _isFetchingMore = false;
  final int _pageSize = 100;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    final folderId = widget.folder.id;

    // Check if assets are already cached
    if (_cachedAssets.containsKey(folderId)) {
      assets = _cachedAssets[folderId]!;
      setState(() {
        _isLoading = false;
      });
    } else {
      await _fetchAssets(); // Fetch if not cached
    }
  }

  Future<void> _fetchAssets() async {
    final folderId = widget.folder.id;

    final newAssets = await widget.folder.getAssetListPaged(
      page: currentPage,
      size: _pageSize,
    );
    assets.addAll(newAssets);
    _cachedAssets[folderId] = assets;

    setState(() {
      _isLoading = false;
      _isFetchingMore = false;
    });
  }

  void _loadMore() {
    if (_isFetchingMore) return;
    setState(() {
      _isFetchingMore = true;
      currentPage++;
    });
    _fetchAssets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.name),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent && !_isFetchingMore) {
            _loadMore(); // Load more assets when scroll reaches the bottom
          }
          return false;
        },
        child: GridView.builder(
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
      ),
    );
  }
}
