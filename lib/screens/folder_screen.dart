import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../widgets/appbar_gradient_custom.dart';
import 'package:photoarc/widgets/images/local_images/asset_thumbnail.dart';
import 'package:photoarc/widgets/navbar.dart';
import '../widgets/dialog_box.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/image_view.dart';
import '../widgets/video_view.dart';

class FolderScreen extends StatefulWidget {
  final AssetPathEntity folder;

  const FolderScreen({super.key, required this.folder});

  @override
  _FolderScreenState createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  static final Map<String, List<AssetEntity>> _cachedAssets = {};
  List<AssetEntity> assets = [];
  Set<AssetEntity> _selectedAssets = {}; // Use AssetEntity for tracking selection
  bool _isSelectionMode = false;
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

    assets = await widget.folder.getAssetListRange(start: 0, end: 100000);
    _cachedAssets[folderId] = assets; // Cache the result

    setState(() {
      _isLoading = false;
    });
  }

  void _toggleSelection(AssetEntity asset) {
    HapticFeedback.vibrate();

    setState(() {
      if (_selectedAssets.contains(asset)) {
        _selectedAssets.remove(asset);
        if (_selectedAssets.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedAssets.add(asset);
        _isSelectionMode = true;
      }
    });
  }

  void _selectAllImages() {
    setState(() {
      _selectedAssets = Set<AssetEntity>.from(assets);
      _isSelectionMode = true;
    });
  }

  void _deselectAllImages() {
    setState(() {
      _selectedAssets.clear();
      _isSelectionMode = false;
    });
  }

  Future<void> _confirmDelete() async {
    if (_selectedAssets.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => DialogBox(
        title: 'Delete Images',
        subtitle: 'Are you sure you want to delete the selected images?',
        primaryButtonText: 'Delete',
        secondaryButtonText: 'Cancel',
        primaryButtonAction: () => Navigator.of(context).pop(true),
        secondaryButtonAction: () => Navigator.of(context).pop(false),
        primaryColor: Colors.red,
      ),
    );

    if (confirm == true) {
      await _deleteSelectedImages();
    }
  }

  Future<void> _deleteSelectedImages() async {
    // Prepare a list of asset IDs to delete
    final List<String> assetIds = _selectedAssets.map((asset) => asset.id).toList();

    try {
      // Use the PhotoManager to delete the assets by their IDs
      await PhotoManager.editor.deleteWithIds(assetIds);
      showPrimarySnackbar(context, 'Selected images deleted successfully.');
    } catch (e) {
      showErrorSnackbar(context, 'Error deleting images: $e');
    }

    // Update the UI state after deletion
    setState(() {
      assets.removeWhere((asset) => _selectedAssets.contains(asset));
      _selectedAssets.clear();
      _isSelectionMode = false;
    });
  }

  Future<void> _shareSelectedImages() async {
    if (_selectedAssets.isEmpty) return;

    try {
      // Retrieve the actual files for the selected assets
      final List<File?> selectedFiles = await Future.wait(
        _selectedAssets.map((asset) async => await asset.file).toList(),
      );

      final validFiles = selectedFiles.where((file) => file != null).map((file) => file!).toList();
      final List<XFile> xFiles = validFiles.map((file) => XFile(file.path)).toList();
      if (xFiles.isNotEmpty) {
        Share.shareXFiles(
          xFiles,
          text: 'Check out these images!',
        );
      } else {
        showErrorSnackbar(context, 'No valid images to share.');
      }
    } catch (e) {
      showErrorSnackbar(context, 'Error sharing images: $e');
    }
  }

  void _openImage(AssetEntity asset) {
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

  @override
  Widget build(BuildContext context) {
    // Group assets by creation date
    final groupedAssets = <String, List<AssetEntity>>{};
    for (final asset in assets) {
      final creationDate = asset.createDateTime; // Already a DateTime object
      final dateKey = DateFormat('yyyy-MM-dd').format(creationDate);

      if (groupedAssets[dateKey] == null) {
        groupedAssets[dateKey] = [];
      }
      groupedAssets[dateKey]!.add(asset);
    }

    return Scaffold(
      appBar: AppBarCustom(
        title: widget.folder.name,
        primaryColor: const Color(0xff4338CA),
        secondaryColor: const Color(0xff6D28D9),
        actions: _isSelectionMode
            ? [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _confirmDelete,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareSelectedImages,
          ),
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.white),
            onPressed: _deselectAllImages,
          ),
          IconButton(
            icon: Icon(
              (_selectedAssets.length == assets.length && _selectedAssets.isNotEmpty)
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
              color: Colors.white,
            ),
            onPressed: _selectedAssets.length == assets.length
                ? _deselectAllImages
                : _selectAllImages,
            tooltip: _selectedAssets.length == assets.length ? 'Deselect All' : 'Select All',
          ),
        ]
            : [
          IconButton(
            icon: Icon(
              (_selectedAssets.length == assets.length && _selectedAssets.isNotEmpty)
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
              color: Colors.white,
            ),
            onPressed: _selectedAssets.length == assets.length
                ? _deselectAllImages
                : _selectAllImages,
            tooltip: _selectedAssets.length == assets.length ? 'Deselect All' : 'Select All',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: groupedAssets.entries.map((entry) {
          final date = entry.key;
          final assetsList = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  date,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                ),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: assetsList.length,
                itemBuilder: (_, index) {
                  final asset = assetsList[index];
                  final isSelected = _selectedAssets.contains(asset);

                  return AssetThumbnail(
                    asset: asset,
                    isSelected: isSelected,
                    onTap: () => _selectedAssets.isEmpty ? _openImage(asset) : _toggleSelection(asset),
                    onLongPress: () => _toggleSelection(asset),
                  );
                },
              ),
            ],
          );
        }).toList(),
      ),
      bottomNavigationBar: NavBar(
        primaryColor: const Color(0xff4338CA),
      ),
    );
  }
}
