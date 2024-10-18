import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/images/cloud_images/fullscreen_image.dart';
import '../widgets/images/cloud_images/image_card.dart';
import '../widgets/dialog_box.dart';
import '../widgets/appbar_gradient_custom.dart';
import '../widgets/navbar.dart';

class CloudImagesScreen extends StatefulWidget {
  const CloudImagesScreen({super.key});

  @override
  _CloudImagesScreenState createState() => _CloudImagesScreenState();
}

class _CloudImagesScreenState extends State<CloudImagesScreen> {
  List<Map<String, dynamic>> _imageData = [];
  Set<int> _selectedIndices = {};
  bool _isSelectionMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCloudImages();
  }

  Future<void> _loadCloudImages() async {
    setState(() => _isLoading = true);
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      showErrorSnackbar(context, 'No user is currently logged in.');
      return;
    }

    try {
      final storageRef = FirebaseStorage.instance.ref().child('users/$userId/images');
      final result = await storageRef.listAll();
      final data = await Future.wait(result.items.map((item) async {
        final downloadUrl = await item.getDownloadURL();
        final metadata = await item.getMetadata();
        final uploadTime = metadata.timeCreated;
        return {
          'url': downloadUrl,
          'path': item.fullPath,
          'uploadTime': uploadTime,
        };
      }));

      data.sort((a, b) {
        final dateA = a['uploadTime'] as DateTime? ?? DateTime(0);
        final dateB = b['uploadTime'] as DateTime? ?? DateTime(0);
        return dateB.compareTo(dateA);
      });

      setState(() {
        _imageData = data;
        _isLoading = false;
      });
    } catch (e) {
      showErrorSnackbar(context, 'Failed to load images: $e');
    }
  }

  Future<void> _confirmDelete() async {
    if (_selectedIndices.isEmpty) return;

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
    for (var index in _selectedIndices) {
      final path = _imageData[index]['path'];
      try {
        await FirebaseStorage.instance.ref(path).delete();
      } catch (e) {
        showErrorSnackbar(context, 'Error deleting image: $e');
      }
    }

    setState(() {
      final indicesToRemove = _selectedIndices.toList()..sort((a, b) => b.compareTo(a));
      for (var index in indicesToRemove) {
        _imageData.removeAt(index);
      }
      _selectedIndices.clear();
      _isSelectionMode = false;
    });

    showPrimarySnackbar(context, 'Selected images deleted successfully.');
  }

  void _toggleSelection(int index) {
    HapticFeedback.vibrate();

    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
        if (_selectedIndices.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedIndices.add(index);
        _isSelectionMode = true;
      }
    });
  }

  void _selectAllImages() {
    setState(() {
      _selectedIndices = Set<int>.from(Iterable<int>.generate(_imageData.length));
      _isSelectionMode = true;
    });
  }

  void _deselectAllImages() {
    setState(() {
      _selectedIndices.clear();
      _isSelectionMode = false;
    });
  }

  void _shareSelectedImages() {
    if (_selectedIndices.isEmpty) return;

    final selectedUrls = _selectedIndices.map((index) => _imageData[index]['url']).toList();
    Share.share(selectedUrls.join('\n'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(
        title: "PhotoArc",
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
              (_selectedIndices.length == _imageData.length && _selectedIndices.length > 0)
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
              color: Colors.white,
            ),
            onPressed: _selectedIndices.length == _imageData.length
                ? _deselectAllImages
                : _selectAllImages,
            tooltip: _selectedIndices.length == _imageData.length ? 'Deselect All' : 'Select All',
          ),
        ]
            : [
          IconButton(
            icon: Icon(
              (_selectedIndices.length == _imageData.length && _selectedIndices.length > 0)
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
              color: Colors.white,
            ),
            onPressed: _selectedIndices.length == _imageData.length
                ? _deselectAllImages
                : _selectAllImages,
            tooltip: _selectedIndices.length == _imageData.length ? 'Deselect All' : 'Select All',
          ),
        ],
      ),
      bottomNavigationBar: NavBar( // Use the NavBar at the bottom
        selectedTab: 2,
        primaryColor: const Color(0xff4338CA),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _imageData.isEmpty
          ? const Center(
        child: Text(
          'No images found.\nPlease upload images to see them here.',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      )
          : Stack(
        children: [
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
            ),
            itemCount: _imageData.length,
            itemBuilder: (_, index) {
              final imageData = _imageData[index];
              final isSelected = _selectedIndices.contains(index);

              return ImageCard(
                imageUrl: imageData['url'],
                uploadTime: imageData['uploadTime'],
                isSelected: isSelected,
                onTap: () => _selectedIndices.isEmpty
                    ? Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        FullScreenImage(imageUrl: imageData['url']),
                  ),
                )
                    : _toggleSelection(index),
                onLongPress: () => _toggleSelection(index),
              );
            },
          ),
        ],
      ),
    );
  }
}
