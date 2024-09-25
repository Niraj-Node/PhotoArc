import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CloudImagesScreen extends StatefulWidget {
  const CloudImagesScreen({super.key});

  @override
  _CloudImagesScreenState createState() => _CloudImagesScreenState();
}

class _CloudImagesScreenState extends State<CloudImagesScreen> {
  List<String> _imageUrls = [];
  List<String> _imagePaths = []; // Store image paths for deletion
  Set<int> _selectedIndices = {}; // Track selected images

  @override
  void initState() {
    super.initState();
    _loadCloudImages();
  }

  Future<void> _loadCloudImages() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      _showSnackBar('No user is currently logged in.');
      return;
    }

    final storageRef = FirebaseStorage.instance.ref().child('users/$userId/images');
    final result = await storageRef.listAll();

    final urls = await Future.wait(result.items.map((item) async {
      final downloadUrl = await item.getDownloadURL();
      _imagePaths.add(item.fullPath); // Store the image path for deletion
      return downloadUrl;
    }));

    setState(() {
      _imageUrls = urls;
    });
  }

  Future<void> _deleteSelectedImages() async {
    for (var index in _selectedIndices) {
      final path = _imagePaths[index];
      try {
        await FirebaseStorage.instance.ref(path).delete(); // Delete from Firebase Storage
      } catch (e) {
        _showSnackBar('Error deleting image: $e');
      }
    }

    // Create new lists excluding the deleted indices
    final newImageUrls = <String>[];
    final newImagePaths = <String>[];

    for (int i = 0; i < _imageUrls.length; i++) {
      if (!_selectedIndices.contains(i)) {
        newImageUrls.add(_imageUrls[i]);
        newImagePaths.add(_imagePaths[i]);
      }
    }

    setState(() {
      _imageUrls = newImageUrls;
      _imagePaths = newImagePaths;
      _selectedIndices.clear();
    });

    _showSnackBar('Selected images deleted successfully.');
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uploaded Images'),
        actions: [
          if (_selectedIndices.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelectedImages,
            ),
        ],
      ),
      body: _imageUrls.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No images found.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please upload images to see them here.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: _imageUrls.length,
        itemBuilder: (_, index) {
          final isSelected = _selectedIndices.contains(index);
          return GestureDetector(
            onTap: () {
              // Navigate to the full-screen image viewer when an image is tapped
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenImage(imageUrl: _imageUrls[index]),
                ),
              );
            },
            onLongPress: () => _toggleSelection(index), // Select on long press
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: _imageUrls[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                if (isSelected) // Show selection overlay
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    alignment: Alignment.center,
                    child: const Icon(Icons.check, color: Colors.white),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Full screen image viewer with PhotoView
class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoView(
            imageProvider: CachedNetworkImageProvider(imageUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 5,
            heroAttributes: const PhotoViewHeroAttributes(tag: 'imageHero'),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
