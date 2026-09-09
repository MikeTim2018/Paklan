import 'package:dartz/dartz.dart';
import 'package:paklan/core/usecase/usecase.dart';
import 'package:paklan/data/common/models/message.dart';
import 'package:paklan/domain/common/repository/common_repository.dart';
import 'package:paklan/service_locator.dart';

class RegisterMessageUseCase extends UseCase<Either, MessageModel>{
  @override
  Future <Either> call({MessageModel ? params}) async{
    return await sl<CommonRepository>().registerMessage(params!);
  }
}