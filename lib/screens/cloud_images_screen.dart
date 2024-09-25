import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class CloudImagesScreen extends StatefulWidget {
  const CloudImagesScreen({super.key});

  @override
  _CloudImagesScreenState createState() => _CloudImagesScreenState();
}

class _CloudImagesScreenState extends State<CloudImagesScreen> {
  List<Map<String, dynamic>> _imageData = [];
  Set<int> _selectedIndices = {};
  bool _isSelectionMode = false;
  bool _isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _loadCloudImages();
  }

  Future<void> _loadCloudImages() async {
    setState(() {
      _isLoading = true; // Start loading
    });
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      _showSnackBar('No user is currently logged in.');
      return;
    }

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
      _isLoading = false; // End loading
    });
  }

  void _toggleSelection(int index) {
    HapticFeedback.vibrate();

    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
        if (_selectedIndices.isEmpty) {
          _isSelectionMode = false; // Exit selection mode when none selected
        }
      } else {
        _selectedIndices.add(index);
        _isSelectionMode = true; // Enter selection mode when an image is selected
      }
    });
  }

  Future<void> _confirmDelete() async {
    if (_selectedIndices.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Images'),
        content: const Text('Are you sure you want to delete the selected images?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
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
        _showSnackBar('Error deleting image: $e');
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

    _showSnackBar('Selected images deleted successfully.');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    ));
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
      appBar: AppBar(
        title: const Text('Uploaded Images', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(
                ( (_selectedIndices.length == _imageData.length) && (_selectedIndices.length > 0) )
                    ? Icons.check_box  // All selected (filled checkbox)
                    : Icons.check_box_outline_blank  // Not all selected (empty checkbox)
            ),
            onPressed: _selectedIndices.length == _imageData.length
                ? _deselectAllImages
                : _selectAllImages,
            tooltip: _selectedIndices.length == _imageData.length ? 'Deselect All' : 'Select All',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Loading indicator
          : _imageData.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No images found.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Please upload images to see them here.', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
          ],
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
              final formattedDate = DateFormat('MMM dd, yyyy').format(imageData['uploadTime']);

              return GestureDetector(
                onTap: () {
                  if (_selectedIndices.isEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImage(imageUrl: imageData['url']),
                      ),
                    );
                  } else {
                    _toggleSelection(index);
                  }
                },
                onLongPress: () => _toggleSelection(index),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Stack(
                    children: [
                      Opacity(
                        opacity: isSelected ? 0.5 : 1.0,
                        child: CachedNetworkImage(
                          imageUrl: imageData['url'],
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      if (_selectedIndices.isNotEmpty)
                        Positioned(
                          right: 5,
                          top: 5,
                          child: Checkbox(
                            value: isSelected,
                            onChanged: (bool? value) {
                              _toggleSelection(index);
                            },
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
            },
          ),
          if (_isSelectionMode)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${_selectedIndices.length} image(s) selected', style: const TextStyle(color: Colors.white)),
                    Row(
                      children: [
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
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PhotoView(
        imageProvider: NetworkImage(imageUrl),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2,
      ),
    );
  }
}
