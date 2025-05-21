import 'package:dartz/dartz.dart';
import 'package:paklan/core/usecase/usecase.dart';
import 'package:paklan/data/transactions/models/new_transaction.dart';
import 'package:paklan/domain/transactions/repository/transaction.dart';
import 'package:paklan/service_locator.dart';

class CreateTransactionUseCase extends UseCase<Either, NewTransactionModel>{
  @override
  Future <Either> call({NewTransactionModel ? params}) async{
    return await sl<TransactionRepository>().createTransaction(params!);
  }
}