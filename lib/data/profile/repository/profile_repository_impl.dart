import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:paklan/data/profile/source/profile_firebase_service.dart';
import 'package:paklan/domain/profile/repository/profile.dart';
import 'package:paklan/service_locator.dart';


class ProfileRepositoryImpl extends ProfileRepository{
  @override
  Future<Either> uploadProfilePicture(File picture) {
    return sl<ProfileFirebaseService>().uploadProfilePicture(picture);
  }
  
}