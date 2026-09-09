import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:uuid/uuid.dart';

class PhotoHelperFunctions {
  
  List<String> generatePaths(dynamic listModel, String currentUser){
    const uuid = Uuid();
    return List.generate(listModel.images!.length, (index) {
     // 1. Get the actual file extension from the picked file (e.g., '.png', '.heic', '.jpg')
       String ext = p.extension(listModel.images![index].path);
       if (ext.isEmpty) ext = '.jpg'; 
       return 'uploads/$currentUser/${uuid.v4()}_img$ext';
      });
  }
  String generateSinglePath(String path, String currentUser){
    const uuid = Uuid();
    String ext = p.extension(path);
    if (ext.isEmpty) ext = '.jpg'; 
    return 'uploads/$currentUser/${uuid.v4()}_img$ext';
  }
  Future<List<String>> uploadImagesAndWaitForResize({
  required List<File> images,
  required List<String> originalPaths,
  required String resizeSuffix,
}) async {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final List<UploadTask> uploadTasks = [];

  // 1. Start all batch uploads for the ORIGINAL images simultaneously
  for (int i = 0; i < images.length; i++) {
    final ref = storage.ref().child(originalPaths[i]);
    final task = ref.putFile(
      images[i]
    );
    uploadTasks.add(task);
  }

  // Wait for all original uploads to complete
  await Future.wait(uploadTasks);

  // 2. Build the paths for the RESIZED images and poll for their URLs
  final List<Future<String>> urlFutures = [];
  
  for (String originalPath in originalPaths) {
    // Inject the suffix into the path (e.g., 'img.jpg' -> 'img_200x200.jpg')
    final extensionIndex = originalPath.lastIndexOf('.');
    final resizedPath = '${originalPath.substring(0, extensionIndex)}$resizeSuffix${originalPath.substring(extensionIndex)}';
    
    final resizedRef = storage.ref().child(resizedPath);
    
    // Add the polling function to our futures list
    urlFutures.add(_getResizedUrlWithRetry(resizedRef));
  }

  // Resolve and return all resized URLs
  return Future.wait(urlFutures);
}
  /// Helper function to handle the race condition with the Firebase Extension
Future<String> _getResizedUrlWithRetry(Reference ref, {int maxRetries = 6}) async {
  int attempt = 0;
  
  while (attempt < maxRetries) {
    try {
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        // The extension hasn't finished creating the file yet.
        attempt++;
        if (attempt >= maxRetries) {
          throw Exception('Timeout waiting for Firebase Extension to resize image.');
        }
        await Future.delayed(const Duration(milliseconds: 1750));
      } else if (e.code == 'permission-denied') {
        try {
          final token = const Uuid().v4();
          await ref.updateMetadata(SettableMetadata(
            customMetadata: {'firebaseStorageDownloadTokens': token},
          ));
          return await ref.getDownloadURL();
        } catch (innerError) {
          rethrow; 
        }
      } else {
        rethrow; 
      }
    }
  }
  throw Exception('Failed to fetch resized image.');
}


}