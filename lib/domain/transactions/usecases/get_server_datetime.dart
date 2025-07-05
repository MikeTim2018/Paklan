import 'package:dartz/dartz.dart';
import 'package:paklan/core/usecase/usecase.dart';
import 'package:paklan/domain/transactions/repository/transaction.dart';
import 'package:paklan/service_locator.dart';

class GetServerDatetimeUseCase extends UseCase<Either, String>{
  @override
  Future <Either> call({String ? params}) async{
    return await sl<TransactionRepository>().getServerDateTime();
  }
}