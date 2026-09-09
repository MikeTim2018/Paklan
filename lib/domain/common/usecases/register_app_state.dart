import 'package:dartz/dartz.dart';
import 'package:paklan/core/usecase/usecase.dart';
import 'package:paklan/domain/common/repository/common_repository.dart';
import 'package:paklan/service_locator.dart';

class RegisterAppStateUseCase extends UseCase<Either, bool>{
  @override
  Future <Either> call({bool ? params}) async{
    return await sl<CommonRepository>().registerAppState(params!);
  }
}