import 'package:dartz/dartz.dart';
import 'package:paklan/core/usecase/usecase.dart';
import 'package:paklan/data/transactions/models/status.dart';
import 'package:paklan/domain/transactions/repository/transaction.dart';
import 'package:paklan/service_locator.dart';

class UpdateDealUseCase extends UseCase<Either, StatusModel>{
  @override
  Future <Either> call({StatusModel ? params}) async{
    return await sl<TransactionRepository>().updateDeal(params!);
  }
}