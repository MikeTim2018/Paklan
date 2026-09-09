import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paklan/common/helper/photo_upload/photo_helper_functions.dart';

abstract class ProfileFirebaseService {
  Future<Either> uploadProfilePicture(File user);
}

class ProfileFirebaseServiceImpl extends ProfileFirebaseService{

  @override
  Future<Either<dynamic, dynamic>> uploadProfilePicture(File image) async {
    try{
      dynamic photoHelper = PhotoHelperFunctions();
      var currentUser = FirebaseAuth.instance.currentUser;
      if(currentUser == null){
        return left("User not logged in");
      }
      String storagePath = photoHelper.generateSinglePath(image.path, currentUser.uid);
      List<File> images = [image];
      List<String> paths = [storagePath];
      List<String> downloadUrl = await photoHelper.uploadImagesAndWaitForResize(
        images: images,
        originalPaths: paths,
        resizeSuffix: '_700x700'
        );
      var userRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
      userRef.update({'photoLink': downloadUrl[0]});
      return right("ok");
    }catch(e){
      return Left(e);
  }
  }
}