import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paklan/domain/transactions/repository/transaction.dart';
import 'package:paklan/service_locator.dart';

class GetClabesUseCase{
  Stream<DocumentSnapshot<Map<String, dynamic>>> call({dynamic params}) {
    return sl<TransactionRepository>().getClabes();
  }
}