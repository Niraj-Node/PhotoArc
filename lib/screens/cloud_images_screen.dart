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

    final urls = await Future.wait(result.items.map((item) => item.getDownloadURL()));
    setState(() {
      _imageUrls = urls;
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
      ),
      body: _imageUrls.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: _imageUrls.length,
        itemBuilder: (_, index) {
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
            child: CachedNetworkImage(
              imageUrl: _imageUrls[index],
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.error),
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
