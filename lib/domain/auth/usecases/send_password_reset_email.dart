import 'package:dartz/dartz.dart';
import 'package:paklan/core/usecase/usecase.dart';
import 'package:paklan/domain/auth/repository/auth.dart';
import 'package:paklan/service_locator.dart';

class SendPasswordResetEmailUseCase implements UseCase<Either, String>{
  @override
  Future<Either> call({String ? params}) async{
    return await sl<AuthRepository>().sendPasswordResetEmail(params!);
  }

}