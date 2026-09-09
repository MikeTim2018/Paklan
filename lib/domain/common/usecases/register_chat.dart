import 'package:dartz/dartz.dart';
import 'package:paklan/core/usecase/usecase.dart';
import 'package:paklan/data/common/models/chat.dart';
import 'package:paklan/domain/common/repository/common_repository.dart';
import 'package:paklan/service_locator.dart';

class RegisterChatUseCase extends UseCase<Either, ChatModel>{
  @override
  Future <Either> call({ChatModel ? params}) async{
    return await sl<CommonRepository>().registerChat(params!);
  }
}