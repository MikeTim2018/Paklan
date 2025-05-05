import 'package:dartz/dartz.dart';
import 'package:packlan_alpha/core/usecase/usecase.dart';
import 'package:packlan_alpha/domain/auth/repository/auth.dart';
import 'package:packlan_alpha/service_locator.dart';

class GetUserUseCase implements UseCase<Either, dynamic>{
  @override
  Future<Either> call({params}) async{
    return await sl<AuthRepository>().getUser();
  }

}