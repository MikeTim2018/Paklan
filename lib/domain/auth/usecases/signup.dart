import 'package:dartz/dartz.dart';
import 'package:paklan/core/usecase/usecase.dart';
import 'package:paklan/data/auth/models/user_creation_req.dart';
import 'package:paklan/domain/auth/repository/auth.dart';
import 'package:paklan/service_locator.dart';

class SignupUseCase implements UseCase<Either, UserCreationReq>{
  @override
  Future<Either> call({UserCreationReq ? params}) async{
    return await sl<AuthRepository>().signup(params!);
  }

}