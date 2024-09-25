import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photoarc/widgets/folder_grid.dart';
import 'package:photoarc/utils/routes.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<AssetPathEntity>? _folders;

  @override
  void initState() {
    super.initState();
    _loadFolders(); // Load folders when the widget is initialized
  }

  Future<void> _loadFolders() async {
    // retrieves a list of AssetPathEntity objects
    // AssetPathEntity is a class from the photo_manager package that represents a folder or album on the device
    // Each AssetPathEntity object contains several properties
    // like id, name, assetCount, type,
    final result = await PhotoManager.getAssetPathList(
        type: RequestType.common);
    setState(() {
      _folders = result;
    });
  }

  Future<void> _handleCameraAction(BuildContext context) async {
    final cameraStatus = await Permission.camera.status;

    if (!cameraStatus.isGranted) {
      final result = await Permission.camera.request();
      if (!result.isGranted) {
        return;
      }
    }

    // If the camera permission is granted, navigate to the CameraScreen
    Navigator.of(context).pushNamed(Routes.camera);
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Optionally, navigate to the login screen or another screen after sign out
      Navigator.of(context).pushReplacementNamed(Routes.signin); // Adjust this to your login route
    } catch (e) {
      print('Error signing out: $e');
      _showSnackBar('Error signing out. Please try again.');
    }
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
        title: const Text('PhotoArc'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt, size: 30),
            onPressed: () => _handleCameraAction(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 30), // Sign-out icon
            onPressed: _signOut,
          ),
        ],
      ),
      body: _folders == null
          ? const Center(child: CircularProgressIndicator())
          : FolderGrid(
        folders: _folders!,
        onFolderTap: _onFolderTap,
      ),
    );
  }

  // This callback is provided to the grid to handle folder taps.
  // It is passed down to each folder card. The function is executed
  // when a folder card is tapped, navigating to the FolderScreen
  // with the selected folder's AssetPathEntity.
  void _onFolderTap(AssetPathEntity folder) {
    Navigator.of(context).pushNamed(
      Routes.folder,
      arguments: folder,
    );
  }
}
