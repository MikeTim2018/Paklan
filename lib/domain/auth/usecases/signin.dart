import 'package:dartz/dartz.dart';
import 'package:paklan/core/usecase/usecase.dart';
import 'package:paklan/data/auth/models/user_signin.dart';
import 'package:paklan/domain/auth/repository/auth.dart';
import 'package:paklan/service_locator.dart';

class SigninUseCase implements UseCase<Either, UserSigninReq>{
  @override
  Future<Either> call({UserSigninReq ? params}) async{
    return await sl<AuthRepository>().signin(params!);
  }

}