import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:paklan/data/in_search_of/models/in_search_of.dart';
import 'package:paklan/data/in_search_of/source/in_search_of_service.dart';
import 'package:paklan/data/transactions/models/transaction.dart';
import 'package:paklan/data/transactions/source/transaction_firebase_service.dart';
import 'package:paklan/domain/in_search_of/repository/in_search_of_repository.dart';
import 'package:paklan/service_locator.dart';

class InSearchOfRepositoryImpl extends InSearchOfRepository{
  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getISOPosts() {
    Stream<QuerySnapshot<Map<String, dynamic>>> transactions = sl<InSearchOfService>().getISOPosts();
    return transactions;
  }
  
  @override
  Future<Either> getISOPost(String searchVal) async{
    Either transactions = await sl<InSearchOfService>().getISOPost(searchVal);
    return transactions.fold(
      (error){
        return Left(error);
      }, 
      (data){
        return Right(
          List.from(data).map((e) => InSearchOfModel.fromMap(e).toEntity()).toList()
          );
      }
      );
  }

  @override
  Future<Either> createISOPost(InSearchOfModel newPost) async{
    return await sl<InSearchOfService>().createISOPost(newPost);
  }
  
  @override
  Map<String, dynamic> getTransaction(TransactionModel transaction){
    return sl<TransactionFirebaseService>().getTransaction(transaction);
  }
  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getCompletedTransactions(){
    Stream<QuerySnapshot<Map<String, dynamic>>> transactions = sl<TransactionFirebaseService>().getCompletedTransactions();
    return transactions;
  }
  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> getISOPostStream(String transactionId) {
    return sl<InSearchOfService>().getISOPostStream(transactionId);
  }


}
