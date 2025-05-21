import 'package:dartz/dartz.dart';
import 'package:paklan/core/usecase/usecase.dart';
import 'package:paklan/domain/auth/repository/auth.dart';
import 'package:paklan/service_locator.dart';

class GetUserUseCase implements UseCase<Either, dynamic>{
  @override
  Future<Either> call({dynamic params}) async{
    return await sl<AuthRepository>().getUser();
  }

}