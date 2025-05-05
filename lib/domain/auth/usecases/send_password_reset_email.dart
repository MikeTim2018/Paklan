import 'package:dartz/dartz.dart';
import 'package:packlan_alpha/core/usecase/usecase.dart';
import 'package:packlan_alpha/domain/auth/repository/auth.dart';
import 'package:packlan_alpha/service_locator.dart';

class SendPasswordResetEmailUseCase implements UseCase<Either, String>{
  @override
  Future<Either> call({String ? params}) async{
    return await sl<AuthRepository>().sendPasswordResetEmail(params!);
  }

}