import 'package:dartz/dartz.dart';
import 'package:paklan/core/usecase/usecase.dart';
import 'package:paklan/domain/transactions/repository/transaction.dart';
import 'package:paklan/service_locator.dart';

class GetTransactionUseCase extends UseCase<Either, dynamic>{
  @override
  Future <Either> call({dynamic params}) async{
    return await sl<TransactionRepository>().getTransaction(params);
  }
}