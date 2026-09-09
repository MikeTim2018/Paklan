
import 'package:dartz/dartz.dart';
import 'package:paklan/core/usecase/usecase.dart';
import 'package:paklan/domain/in_search_of/repository/in_search_of_repository.dart';
import 'package:paklan/service_locator.dart';

class SearchIsoPostsUseCase extends UseCase<Either, String>{
  @override
  Future <Either> call({String ? params}) async{
    return await sl<InSearchOfRepository>().getISOPost(params!);
  }
}