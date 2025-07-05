import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:paklan/data/transactions/models/new_transaction.dart';
import 'package:paklan/data/transactions/models/status.dart';
import 'package:paklan/data/transactions/models/transaction.dart';

abstract class TransactionRepository {
  Stream<QuerySnapshot<Map<String, dynamic>>> getTransactions();
  Future<Either> getPerson(String searchVal);
  Future<Either> createTransaction(NewTransactionModel newTransaction);
  Map<String, dynamic> getTransaction(TransactionModel transaction);
  Future<Either> updateDeal(StatusModel newStatus);
  Stream<QuerySnapshot<Map<String, dynamic>>> getCompletedTransactions();
  Stream<DocumentSnapshot<Map<String, dynamic>>> getClabes();
  Future<Either> deleteClabe(String clabe);
  Future<Either> createClabe(String clabe);
  Future<Either> getServerDateTime();
}