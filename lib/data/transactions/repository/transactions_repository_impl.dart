import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:paklan/data/transactions/models/new_transaction.dart';
import 'package:paklan/data/transactions/models/status.dart';
import 'package:paklan/data/transactions/models/transaction.dart';
import 'package:paklan/data/transactions/models/user.dart';
import 'package:paklan/data/transactions/source/transaction_firebase_service.dart';
import 'package:paklan/domain/transactions/repository/transaction.dart';
import 'package:paklan/service_locator.dart';

class TransactionsRepositoryImpl extends TransactionRepository{
  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getTransactions() {
    Stream<QuerySnapshot<Map<String, dynamic>>> transactions = sl<TransactionFirebaseService>().getTransactions();
    return transactions;
  }
  
  @override
  Future<Either> getPerson(String searchVal) async{
    Either transactions = await sl<TransactionFirebaseService>().getPerson(searchVal);
    return transactions.fold(
      (error){
        return Left(error);
      }, 
      (data){
        return Right(
          List.from(data).map((e) => UserModel.fromMap(e).toEntity()).toList()
          );
      }
      );
  }

  @override
  Future<Either> createTransaction(NewTransactionModel newTransaction) async{
    return await sl<TransactionFirebaseService>().createTransaction(newTransaction);
  }
  
  @override
  Map<String, dynamic> getTransaction(TransactionModel transaction){
    return sl<TransactionFirebaseService>().getTransaction(transaction);
  }

  @override
  Future<Either> updateDeal(StatusModel newStatus) async{
    Either response = await sl<TransactionFirebaseService>().updateDeal(newStatus);
    return response.fold(
      (error){
        return Left(error);
      }, 
      (data){
        return Right(
          data
          );
      }
      );
  }
  Stream<QuerySnapshot<Map<String, dynamic>>> getCompletedTransactions(){
    Stream<QuerySnapshot<Map<String, dynamic>>> transactions = sl<TransactionFirebaseService>().getCompletedTransactions();
    return transactions;
  }
}
