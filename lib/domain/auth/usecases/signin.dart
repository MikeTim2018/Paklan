import 'package:dartz/dartz.dart';
import 'package:packlan_alpha/core/usecase/usecase.dart';
import 'package:packlan_alpha/data/auth/models/user_signin.dart';
import 'package:packlan_alpha/domain/auth/repository/auth.dart';
import 'package:packlan_alpha/service_locator.dart';

class SigninUseCase implements UseCase<Either, UserSigninReq>{
  @override
  Future<Either> call({UserSigninReq ? params}) async{
    return await sl<AuthRepository>().signin(params!);
  }

}