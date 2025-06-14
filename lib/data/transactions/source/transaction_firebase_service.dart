import 'package:algoliasearch/algoliasearch_lite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paklan/core/configs/algolia_configs.dart';
import 'package:paklan/data/transactions/models/new_transaction.dart';
import 'package:paklan/data/transactions/models/status.dart';
import 'package:paklan/data/transactions/models/transaction.dart';

abstract class TransactionFirebaseService{
  Stream<QuerySnapshot<Map<String, dynamic>>> getTransactions();
  Future<Either> getPerson(String searchVal);
  Future<Either> createTransaction(NewTransactionModel newTransaction);
  Map<String,dynamic> getTransaction(TransactionModel transaction);
  Future<Either> updateDeal(StatusModel transaction);
  Stream<QuerySnapshot<Map<String, dynamic>>> getCompletedTransactions();
}

class TransactionFirebaseServiceImpl extends TransactionFirebaseService{

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getTransactions() {
    var currentUser = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance.collection('transactions').where(
           Filter.and(
           Filter("status", isEqualTo: "En proceso"),
           Filter.or(
           Filter("members.buyerId", isEqualTo: currentUser?.uid),
           Filter("members.sellerId", isEqualTo: currentUser?.uid),
      )
    ),
    )
    .orderBy("updatedDate", descending: true)
    .snapshots();
  }
  
  @override
  Future<Either> getPerson(String searchVal) async{
    try{
      var currentUser = FirebaseAuth.instance.currentUser;
      final client = SearchClient(appId: AlgoliaConfigs().appId, apiKey: AlgoliaConfigs().apiKey);
      final query = SearchForHits(
        indexName: AlgoliaConfigs().indexName,
        query: searchVal,
        );
      final result = await client.searchIndex(request: query);
      List<Map<String, dynamic>> finalResult = result.hits.map(
        (e) => e.toJson()
        ).where(
          (e) => e['userId'] != currentUser!.uid
          ).toList();
      return Right(finalResult);
    }
    catch(e){
      return Left(
        "Please try again"
      );
    }
}

  @override
  Future<Either> createTransaction(NewTransactionModel newTransaction) async{
    var currentUser = FirebaseAuth.instance.currentUser;
    try{
    DocumentReference<Map<String, dynamic>> transactionDoc = await FirebaseFirestore.instance.collection("transactions").add(
      {"amount": newTransaction.amount,
       "status": newTransaction.status,
       "members":{
         "sellerFirstName": newTransaction.sellerFirstName,
         "buyerFirstName": newTransaction.buyerFirstName,
         "sellerId": newTransaction.sellerId,
         "buyerId": newTransaction.buyerId
       }
      }
    );
    DocumentReference<Map<String, dynamic>> statusRef = await FirebaseFirestore.instance.collection("transactions/${transactionDoc.id}/status").add(
      {
        "transactionId": transactionDoc.id,
        "buyerConfirmation": newTransaction.buyerConfirmation ?? false,
        "sellerConfirmation": newTransaction.sellerConfirmation ?? false,
        "details": newTransaction.details,
        "status": newTransaction.status,
        "sellerId": newTransaction.sellerId,
        "buyerId": newTransaction.buyerId,
        "cancelled": false,
        "reimbursementDone": false,
        "paymentDone": false,
        "paymentTransferred": false,
        "creationDate": DateTime.timestamp()
      }
    );
    await statusRef.update({"statusId": statusRef.id});
    await FirebaseFirestore.instance.collection("users").doc(currentUser!.uid).update(
      {
        "CLABEs": FieldValue.arrayUnion([newTransaction.clabe])
      }
    );
    return Right("Transaction Created!");
  }catch (error){
    return Left(error);
  }
  }
  
  @override
  Map<String, dynamic> getTransaction(TransactionModel transaction){
    var currentUser = FirebaseAuth.instance.currentUser;
    final Stream<QuerySnapshot<Map<String, dynamic>>> transactionData = FirebaseFirestore
                                    .instance
                                    .collection("transactions")
                                    .doc(transaction.transactionId)
                                    .collection("status")
                                    .orderBy("creationDate", descending: true)
                                    .snapshots();
    return {
      "transactionStream": transactionData, 
      "currentUserId": currentUser!.uid
      } as Map<String, dynamic>;
  }
  
  @override
  Future<Either> updateDeal(StatusModel transactionState) async{
    try{
      var currentUser = FirebaseAuth.instance.currentUser;
      DocumentReference<Map<String, dynamic>> statusRef = await FirebaseFirestore.instance.collection("transactions/${transactionState.transactionId}/status").add(
        {
          "transactionId": transactionState.transactionId,
          "buyerConfirmation": transactionState.buyerConfirmation,
          "sellerConfirmation": transactionState.sellerConfirmation,
          "details": transactionState.details,
          "status": transactionState.status,
          "sellerId": transactionState.sellerId,
          "buyerId": transactionState.buyerId,
          "cancelled": transactionState.cancelled,
          "reimbursementDone": transactionState.reimbursementDone,
          "paymentDone": transactionState.paymentDone,
          "paymentTransferred": transactionState.paymentTransferred,
          "cancelledBy": currentUser!.uid,
          "creationDate": DateTime.timestamp(),
        }
      );
      await statusRef.update({"statusId": statusRef.id});
      return Right("Deal Cancelled!");
    }catch(e){
      return Left(e);
    }
    
  }
  
  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getCompletedTransactions() {
    var currentUser = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance.collection('transactions').where(
           Filter.and(
           Filter.or(
           Filter("status", isEqualTo: "Cancelado"),
           Filter("status", isEqualTo: "Completado"),
           ),
           Filter.or(
           Filter("members.buyerId", isEqualTo: currentUser?.uid),
           Filter("members.sellerId", isEqualTo: currentUser?.uid),
      )
    ),
    )
    .orderBy("updatedDate", descending: true)
    .snapshots();
  }
}