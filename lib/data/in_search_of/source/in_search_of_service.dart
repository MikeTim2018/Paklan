import 'package:algoliasearch/algoliasearch_lite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paklan/common/helper/photo_upload/photo_helper_functions.dart';
import 'package:paklan/core/configs/algolia_configs.dart';
import 'package:paklan/data/in_search_of/models/in_search_of.dart';
import 'package:paklan/data/transactions/models/transaction.dart';


abstract class InSearchOfService{
  Stream<QuerySnapshot<Map<String, dynamic>>> getISOPosts();
  Future<Either> getISOPost(String searchVal);
  Future<Either> createISOPost(InSearchOfModel inSearchOfPost);
  Map<String,dynamic> getTransaction(TransactionModel transaction);
  Stream<QuerySnapshot<Map<String, dynamic>>> getCompletedTransactions();
  Stream<DocumentSnapshot<Map<String, dynamic>>> getISOPostStream(String transactionId);
}

class InSearchOfServiceImpl extends InSearchOfService{

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getISOPosts() {
    return FirebaseFirestore.instance.collection('ISOPosts').where(
           Filter.or(
           Filter("status", isEqualTo: "En busca"),
           Filter("status", isEqualTo: "En proceso"),
           )
    )
    .orderBy("expirationDate", descending: false)
    .limit(200)
    .snapshots();
  }
  
  @override
  Future<Either> getISOPost(String searchVal) async{
    try{
      final client = SearchClient(appId: AlgoliaConfigs().appId, apiKey: AlgoliaConfigs().apiKey);
      final query = SearchForHits(
        indexName: AlgoliaConfigs().isoIndexName,
        query: searchVal,
        );
      final result = await client.searchIndex(request: query);
      List<Map<String, dynamic>> finalResult = result.hits.map(
        (e) => e.toJson()
        ).where(
          (e) => e['status'] == 'En busca'
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
  Future<Either> createISOPost(InSearchOfModel inSearchOfPost) async{
    try{
    String currentUser = FirebaseAuth.instance.currentUser!.uid;
    dynamic photoHelper = PhotoHelperFunctions();
    final List<String> generatedPaths = photoHelper.generatePaths(inSearchOfPost, currentUser);
    List<String> urls = await photoHelper.uploadImagesAndWaitForResize(
      images: inSearchOfPost.images!, 
      originalPaths: generatedPaths,
      resizeSuffix: '_700x700',
    );
    DocumentReference<Map<String, dynamic>> transactionDoc = await FirebaseFirestore.instance.collection("ISOPosts").add(
      {"name": inSearchOfPost.name,
       "reward": inSearchOfPost.reward ?? '????',
       "status": inSearchOfPost.status,
       "imageUrls": urls,
       "dealDetails": inSearchOfPost.dealDetails,
       "details": inSearchOfPost.details,
       "typeOfProduct": inSearchOfPost.typeOfProduct,
       "buyerDisplayName": inSearchOfPost.buyerDisplayName,
       "buyerId": currentUser,
       "typeOfDeal": inSearchOfPost.typeOfDeal,
       "expirationDate": DateTime.now().add(const Duration(days: 30)), // ### WARNING ### this is a temporary solution, the expiration date should be set by the server
      }
    );
    DocumentReference<Map<String, dynamic>> statusRef = await FirebaseFirestore.instance.collection("ISOPosts/${transactionDoc.id}/status").add(
      {
        "transactionId": transactionDoc.id,
        "status": inSearchOfPost.status,
        "details": inSearchOfPost.dealDetails,
        "buyerId": inSearchOfPost.buyerId,
      }
    );
    DocumentReference<Map<String, dynamic>> chatRef = await FirebaseFirestore.instance.collection("chats").add({
      'lastReadTime': null,
      'lastSenderId': null,
      'messageId': null,
      'members': FieldValue.arrayUnion([currentUser]),
      'lastMessage': null,
      'lastMessageTime': null,
      'createdDate': FieldValue.serverTimestamp(),
      'transactionId': transactionDoc.id,
    });
    await chatRef.update({
      'chatId': chatRef.id,
    });
    await transactionDoc.update(
      {
        "transactionId": transactionDoc.id,
        "statusId": statusRef.id,
        "chatId": chatRef.id,
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
  Stream<DocumentSnapshot<Map<String, dynamic>>> getISOPostStream(String transactionId) {
    final Stream<DocumentSnapshot<Map<String, dynamic>>> isoData = FirebaseFirestore
                                    .instance
                                    .collection("ISOPosts")
                                    .doc(transactionId)
                                    .snapshots();
    return isoData;
  }
}