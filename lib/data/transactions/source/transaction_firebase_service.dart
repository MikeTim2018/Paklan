import 'package:algoliasearch/algoliasearch_lite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
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
  Stream<DocumentSnapshot<Map<String, dynamic>>> getClabes();
  Future<Either> deleteClabe(String clabe);
  Future<Either> createClabe(String clabe);
  Future<Either> getServerDateTime();
}

class TransactionFirebaseServiceImpl extends TransactionFirebaseService{

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getTransactions() {
    var currentUser = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance.collection('transactions').where(
           Filter.and(
           Filter.or(
           Filter("status", isEqualTo: "Enviado"),
           Filter("status", isEqualTo: "Depositado"),
           Filter("status", isEqualTo: "Aceptado"),
           ),
           Filter.or(
           Filter("members.buyerId", isEqualTo: currentUser?.uid),
           Filter("members.sellerId", isEqualTo: currentUser?.uid),
      )
    ),
    )
    .orderBy("timeLimit", descending: false)
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
    HttpsCallableResult serverTime = await FirebaseFunctions.instance.httpsCallable('get_time_from_server').call();
    try{
    double transactionAmount = double.parse(newTransaction.amount!);
    String fee;
    if (transactionAmount < 220){
      fee = '15';
    }
    else{
      fee = (transactionAmount * 0.07).truncateToDouble().toStringAsFixed(2);
    }
    DocumentReference<Map<String, dynamic>> transactionDoc = await FirebaseFirestore.instance.collection("transactions").add(
      {"name": newTransaction.name,
        "amount": newTransaction.amount,
        "fee": fee,
       "status": newTransaction.status,
       "members":{
         "sellerFirstName": newTransaction.sellerFirstName,
         "buyerFirstName": newTransaction.buyerFirstName,
         "sellerId": newTransaction.sellerId,
         "buyerId": newTransaction.buyerId,
       },
       "timeLimit": DateTime.parse(serverTime.data['server_datetime']).add(Duration(hours: 24)),
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
        "creationDate": DateTime.parse(serverTime.data['server_datetime'])
      }
    );
    await transactionDoc.update(
      {
        "transactionId": transactionDoc.id,
        "statusId": statusRef.id,
        "updatedDate": DateTime.parse(serverTime.data['server_datetime'])
      }
        );
    await statusRef.update({"statusId": statusRef.id});
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
      HttpsCallableResult serverTime = await FirebaseFunctions.instance.httpsCallable('get_time_from_server').call();
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
          "cancelledBy": transactionState.cancelledBy,
          "creationDate": DateTime.parse(serverTime.data['server_datetime']),
          "cancelMessage": transactionState.cancelMessage,
        }
      );
      await statusRef.update({"statusId": statusRef.id});
      DocumentReference<Map<String, dynamic>> transactionRef = FirebaseFirestore.instance.collection("transactions").doc(transactionState.transactionId);
      if (transactionState.status == 'En proceso' && transactionState.details!.contains("Trato aceptado")){
          await transactionRef.update(
            {
              "status": transactionState.status,
              "timeLimit": DateTime.parse(serverTime.data['server_datetime']).add(Duration(days: 8)),
              "statusId": statusRef.id,
              "updatedDate": DateTime.parse(serverTime.data['server_datetime'])
            }
          );
      }
      else{
        await transactionRef.update(
          {
        "status": transactionState.status,
        "statusId": statusRef.id,
        "updatedDate": DateTime.parse(serverTime.data['server_datetime'])
        }
        );
      }
      return Right("Deal Updated!");
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
  
  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> getClabes() {
    var currentUid = FirebaseAuth.instance.currentUser!.uid;
    Stream<DocumentSnapshot<Map<String, dynamic>>> clabeStream = FirebaseFirestore.instance.collection("users").doc(
        currentUid
      ).snapshots();
    return clabeStream;
  }
  
  @override
  Future<Either> deleteClabe(String clabe) async{
    try{
    var currentUser = FirebaseAuth.instance.currentUser;
      DocumentReference<Map<String, dynamic>> userData = FirebaseFirestore.instance.collection("users").doc(currentUser!.uid);
      List<dynamic> clabesList = await userData.get().then((value)=> value["CLABEs"].where((val) => val != clabe).toList() as List<dynamic>);
      await userData.update({"CLABEs": clabesList});
      return Right("Clabe deleted!");
    } catch(error){
      return Left(error);
    }
  }
  
  @override
  Future<Either> createClabe(String clabe) async{
    try{
    var currentUser = FirebaseAuth.instance.currentUser;
      DocumentReference<Map<String, dynamic>> userData = FirebaseFirestore.instance.collection("users").doc(currentUser!.uid);
      await userData.update({"CLABEs": FieldValue.arrayUnion([clabe])});
      return Right("Clabe Added!");
    } catch(error){
      return Left(error);
    }
  }
  
  @override
  Future<Either> getServerDateTime() async{
    try{
      HttpsCallableResult serverTime = await FirebaseFunctions.instance.httpsCallable('get_time_from_server').call();
      return Right(serverTime);
    } catch(error){
      return Left(error);
    }
  }
}