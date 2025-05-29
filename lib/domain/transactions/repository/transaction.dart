import 'package:dartz/dartz.dart';
import 'package:paklan/data/transactions/models/new_transaction.dart';
import 'package:paklan/data/transactions/models/transaction.dart';

abstract class TransactionRepository {
  Future<Either> getTransactions();
  Future<Either> getPerson(String searchVal);
  Future<Either> createTransaction(NewTransactionModel newTransaction);
  Future<Either> getTransaction(TransactionModel transaction);
}