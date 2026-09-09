import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:paklan/data/in_search_of/models/in_search_of.dart';
import 'package:paklan/data/transactions/models/transaction.dart';

abstract class InSearchOfRepository {
  Stream<QuerySnapshot<Map<String, dynamic>>> getISOPosts();
  Future<Either> getISOPost(String searchVal);
  Future<Either> createISOPost(InSearchOfModel newTransaction);
  Stream<DocumentSnapshot<Map<String, dynamic>>> getISOPostStream(String transactionId);
  Map<String, dynamic> getTransaction(TransactionModel transaction);
  Stream<QuerySnapshot<Map<String, dynamic>>> getCompletedTransactions();
}