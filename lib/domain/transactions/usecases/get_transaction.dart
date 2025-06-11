import 'package:paklan/domain/transactions/repository/transaction.dart';
import 'package:paklan/service_locator.dart';

class GetTransactionUseCase{

  Map<String,dynamic> call({dynamic params}) {
    return sl<TransactionRepository>().getTransaction(params);
  }
}