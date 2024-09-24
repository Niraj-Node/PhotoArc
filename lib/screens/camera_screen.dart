import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isUploading = false;
  double _uploadProgress = 0; // To track upload progress

  @override
  void initState() {
    super.initState();
    _takePicture();
  }

  Future<void> _takePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isUploading = true;
        _uploadProgress = 0; // Reset progress
      });
      await _uploadImageToFirebase(_imageFile!);
    } else {
      _showSnackBar('No image was captured.');
    }
  }

  String? _getCurrentUserId() {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return user.uid;
    } else {
      print('No user is currently logged in.');
      return null;
    }
  }

  Future<void> _uploadImageToFirebase(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final userId = _getCurrentUserId();

      if (userId != null) {
        final fileName = path.basename(imageFile.path);
        final fileRef = storageRef.child('users/$userId/images/$fileName');

        final uploadTask = fileRef.putFile(imageFile);

        // Monitor the upload progress
        uploadTask.snapshotEvents.listen((taskSnapshot) {
          setState(() {
            _uploadProgress = (taskSnapshot.bytesTransferred.toDouble() / taskSnapshot.totalBytes.toDouble()) * 100;
          });
        });

        await uploadTask;

        // Get the download URL of the uploaded file
        final downloadUrl = await fileRef.getDownloadURL();
        print('Uploaded image URL: $downloadUrl');
        _showSnackBar('Upload successful!');
      } else {
        _showSnackBar('Unable to upload image: No user ID found.');
      }
    } catch (e) {
      print('Error uploading image: $e');
      _showSnackBar('Error uploading image: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
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
        title: const Text('Capture Photo'),
      ),
      body: Center(
        child: _isUploading
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(value: _uploadProgress / 100), // Show progress as a percentage
            const SizedBox(height: 20),
            Text('${_uploadProgress.toStringAsFixed(0)}%'), // Display percentage
          ],
        )
            : (_imageFile != null
            ? Image.file(
          _imageFile!,
          fit: BoxFit.cover,
        )
            : const Text('No image selected.')),
      ),
    );
  }
}
