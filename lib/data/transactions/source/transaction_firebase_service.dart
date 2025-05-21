import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paklan/data/transactions/models/new_transaction.dart';

abstract class TransactionFirebaseService{
  Future<Either> getTransactions();
  Future<Either> getPerson(String searchVal);
  Future<Either> createTransaction(NewTransactionModel newTransaction);
}

class TransactionFirebaseServiceImpl extends TransactionFirebaseService{

  @override
  Future<Either> getTransactions() async{
    try{
      var currentUser = FirebaseAuth.instance.currentUser;
      List<QueryDocumentSnapshot<Map<String, dynamic>>> transactionData = await FirebaseFirestore.instance.collection("transactions").where(
      Filter.and(
        Filter("status", isEqualTo: "En proceso"),
        Filter.or(
        Filter("members.buyerId", isEqualTo: currentUser?.uid),
        Filter("members.sellerId", isEqualTo: currentUser?.uid),
        )
      ),
    )
    .get()
    .then(
      (value) => value.docs
      );
      return Right(transactionData.map((e) => e.data()).toList());
    }
    catch(e){
      return Left(
        "Please try again"
      );
    }
  }
  
  @override
  Future<Either> getPerson(String searchVal) async{
    try{
      var currentUser = FirebaseAuth.instance.currentUser;
      List<QueryDocumentSnapshot<Map<String, dynamic>>> userData = await FirebaseFirestore.instance.collection("users").where(
        Filter.and(
        //Filter("firstName", isGreaterThanOrEqualTo: searchVal),
        Filter("userId", isNotEqualTo: currentUser?.uid),
        Filter.or(
        //Filter("firstName", isGreaterThanOrEqualTo: searchVal),
        Filter("email", isGreaterThanOrEqualTo: searchVal),
        Filter("phone", isGreaterThanOrEqualTo: searchVal),
        )
        )
    )
    .get()
    .then(
      (value) => value.docs
      );
      return Right(userData.map((e) => e.data()).toList());
    }
    catch(e){
      return Left(
        "Please try again"
      );
    }
}

  @override
  Future<Either> createTransaction(NewTransactionModel newTransaction) async{
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
    await FirebaseFirestore.instance.collection("transactions/${transactionDoc.id}/status").doc().set(
      {
        "transactionId": transactionDoc.id,
        "buyerConfirmation": newTransaction.buyerConfirmation ?? false,
        "sellerConfirmation": newTransaction.sellerConfirmation ?? false,
        "details": newTransaction.details,
        "status": newTransaction.status,
        "creationDate": DateTime.timestamp()
      }
    );
    return Right("Transaction Created!");
  }catch (error){
    return Left(error);
  }
  }
}