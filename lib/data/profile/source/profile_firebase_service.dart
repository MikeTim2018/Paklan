import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

abstract class ProfileFirebaseService {
  Future<Either> uploadProfilePicture(File user);
}

class ProfileFirebaseServiceImpl extends ProfileFirebaseService{

  Future<String> uploadImage({
    required File image,
    required String storagePath,
  }) async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    final UploadTask uploadTask;

    final ref = storage.ref().child(storagePath);
    final task = ref.putFile(
      image, 
      SettableMetadata(contentType: 'image/jpeg'),
    );
    uploadTask = task;
    return await uploadTask.whenComplete(() => null).then((snapshot) async {
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    });
  }

  @override
  Future<Either<dynamic, dynamic>> uploadProfilePicture(File image) async {
    try{
      var currentUser = FirebaseAuth.instance.currentUser;
      if(currentUser == null){
        return left("User not logged in");
      }
      String storagePath = 'uploads/${currentUser.uid}/profile_${DateTime.now().millisecondsSinceEpoch}_400x400.jpg';
      String downloadUrl = await uploadImage(image: image, storagePath: storagePath);
      var userRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
      userRef.update({'photoLink': downloadUrl});
      return right("ok");
    }catch(e){
      return Left(e);
  }
  }
}