import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:paklan/core/usecase/usecase.dart';
import 'package:paklan/domain/profile/repository/profile.dart';
import 'package:paklan/service_locator.dart';

class UploadProfilePictureUseCase extends UseCase<Either, File>{
  @override
  Future <Either> call({File ? params}) async{
    return await sl<ProfileRepository>().uploadProfilePicture(params!);
  }
}