import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:photoarc/widgets/navbar.dart';
import 'package:photoarc/widgets/images/upload_image_card.dart';
import 'package:photoarc/utils/snackbar_utils.dart';
import 'package:photoarc/utils/file_utils.dart';

import '../widgets/appbar_gradient.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isUploading = false;
  double _uploadProgress = 0;

  @override
  void initState() {
    super.initState();
    _takePicture(); // Automatically open camera on screen load
  }

  Future<void> _takePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    } else {
      showErrorSnackbar(context, 'No image was captured.');
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
    });

    try {
      final storageRef = FirebaseStorage.instance.ref();
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        final fileName = path.basename(_imageFile!.path);
        final fileRef = storageRef.child('users/$userId/images/$fileName');

        final uploadTask = fileRef.putFile(_imageFile!);

        uploadTask.snapshotEvents.listen((taskSnapshot) {
          setState(() {
            _uploadProgress = (taskSnapshot.bytesTransferred.toDouble() /
                taskSnapshot.totalBytes.toDouble()) *
                100;
          });
        });

        await uploadTask;

        final downloadUrl = await fileRef.getDownloadURL();
        showPrimarySnackbar(context, 'Upload successful!');
      } else {
        showErrorSnackbar(context, 'No user ID found.');
      }
    } catch (e) {
      showErrorSnackbar(context, 'Error uploading image: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
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
        selectedTab: 1,
        primaryColor: const Color(0xff4338CA),
      ),
      body: Center(
        child: _isUploading
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(value: _uploadProgress / 100),
            const SizedBox(height: 20),
            Text('${_uploadProgress.toStringAsFixed(0)}%'),
          ],
        )
            : (_imageFile != null
            ? UploadImageCard(
          imageFile: _imageFile!,
          onRetake: _takePicture,
          onUpload: _uploadImage,
          onShare: () => shareImage(context, _imageFile), // Using utility function
          onDownload: () => downloadImage(context, _imageFile), // Using utility function
        )
            : const Text('No image selected.')),
      ),
    );
  }
}
