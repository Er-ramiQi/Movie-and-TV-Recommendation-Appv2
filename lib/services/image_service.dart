import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();
  
  Future<String?> pickAndSaveImage({required ImageSource source}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (image == null) return null;
      
      final String uniqueId = const Uuid().v4();
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagePath = '${appDir.path}/profile_images/$uniqueId.jpg';
      
      // Ensure directory exists
      final Directory imageDir = Directory('${appDir.path}/profile_images');
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }
      
      // Copy image to app directory
      final File savedImage = File(imagePath);
      await savedImage.writeAsBytes(await File(image.path).readAsBytes());
      
      return imagePath;
    } catch (e) {
      debugPrint('Error picking/saving image: $e');
      return null;
    }
  }
  
  Future<void> deleteImage(String path) async {
    try {
      final File imageFile = File(path);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
    } catch (e) {
      debugPrint('Error deleting image: $e');
    }
  }
  
  ImageProvider getProfileImageProvider(String? path) {
    if (path == null || path.isEmpty) {
      return const AssetImage('assets/images/default_avatar.png');
    }
    
    if (path.startsWith('http')) {
      return NetworkImage(path);
    } else {
      return FileImage(File(path));
    }
  }
}