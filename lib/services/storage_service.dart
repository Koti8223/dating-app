import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload profile photo and return download URL
  Future<String> uploadProfilePhoto({
    required String uid,
    required File imageFile,
  }) async {
    final ref = _storage.ref().child('profile_photos/$uid.jpg');

    await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  }
}
