import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photoarc/utils/routes.dart';
import 'package:photoarc/widgets/images/local_images/folder_grid.dart';
import 'package:photoarc/widgets/navbar.dart';
import 'package:photoarc/widgets/appbar_gradient.dart';

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
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final result = await PhotoManager.getAssetPathList(type: RequestType.common);
    setState(() {
      _folders = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarGradient(
        title: 'PhotoArc',
        primaryColor: Color(0xff4338CA),
        secondaryColor: Color(0xff6D28D9),
      ),
      bottomNavigationBar: NavBar(
        selectedTab: 0,
        primaryColor: const Color(0xff4338CA),
      ),
      body: _folders == null
          ? const Center(child: CircularProgressIndicator())
          : FolderGrid(
        folders: _folders!,
        onFolderTap: _onFolderTap,
      ),
    );
  }

  void _onFolderTap(AssetPathEntity folder) {
    Navigator.of(context).pushNamed(
      Routes.folder,
      arguments: folder,
    );
  }
}
