import 'package:dartz/dartz.dart';
import 'package:packlan_alpha/core/usecase/usecase.dart';
import 'package:packlan_alpha/data/auth/models/user_creation_req.dart';
import 'package:packlan_alpha/domain/auth/repository/auth.dart';
import 'package:packlan_alpha/service_locator.dart';

class SignupUseCase implements UseCase<Either, UserCreationReq>{
  @override
  Future<Either> call({UserCreationReq ? params}) async{
    return await sl<AuthRepository>().signup(params!);
  }

}