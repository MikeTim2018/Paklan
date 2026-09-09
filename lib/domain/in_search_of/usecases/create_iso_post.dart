import 'package:dartz/dartz.dart';
import 'package:paklan/core/usecase/usecase.dart';
import 'package:paklan/data/in_search_of/models/in_search_of.dart';
import 'package:paklan/domain/in_search_of/repository/in_search_of_repository.dart';
import 'package:paklan/service_locator.dart';

class CreateIsoPostUseCase extends UseCase<Either, InSearchOfModel>{
  @override
  Future <Either> call({InSearchOfModel ? params}) async{
    return await sl<InSearchOfRepository>().createISOPost(params!);
  }
}