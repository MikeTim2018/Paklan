import 'dart:io';
import 'package:dartz/dartz.dart';

abstract class ProfileRepository {
  Future<Either> uploadProfilePicture(File image);
}