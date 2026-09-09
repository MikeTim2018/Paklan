import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paklan/data/common/models/chat.dart';
import 'package:paklan/data/common/models/message.dart';



abstract class CommonService{
  Future<Either> registerAppState(bool searchVal);
  Stream<DocumentSnapshot<Map<String, dynamic>>> getBuyerProfileStream(String buyerId);
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserProfileStream(String buyerId);
  Future<Either> registerMessage(MessageModel message);
  Future<Either> registerChat(ChatModel message);
  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(String chatId);
  Stream<DocumentSnapshot<Map<String, dynamic>>> getChat(String chatId);
  Future<void> markChatAsRead(String chatId, String userId);

}

class CommonServiceImpl extends CommonService{

  @override
  Future<Either<dynamic, dynamic>> registerAppState(bool active) async{
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Left("User not logged in");
    }
    FirebaseFirestore.instance.collection("users").doc(currentUser.uid).update({
      "active": active,
      "lastActive": FieldValue.serverTimestamp()
    });
    return Right("ok");
  }
  
  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> getBuyerProfileStream(String buyerId) {
    var buyerProfileStream = FirebaseFirestore.instance.collection("buyers").doc(buyerId).snapshots();
    return buyerProfileStream;
  }

   @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserProfileStream(String buyerId) {
    var buyerProfileStream = FirebaseFirestore.instance.collection("users").doc(buyerId).snapshots();
    return buyerProfileStream;
  }
  
  @override
  Future<Either<dynamic, dynamic>> registerMessage(MessageModel message) async{
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Left("User not logged in");
    }
    DocumentReference<Map<String, dynamic>> msgRef = await FirebaseFirestore.instance.collection("chats").doc(message.chatId).collection("messages").add({
      'message': message.message,
      'chatId': message.chatId,
      'senderId': currentUser.uid,
      'senderName': message.senderName,
      'createdTime': FieldValue.serverTimestamp(),
    });
    await msgRef.update({
      'messageId': msgRef.id,
    });
    await FirebaseFirestore.instance.collection("chats").doc(message.chatId).update({
      'lastSenderId': currentUser.uid,
      'messageId': msgRef.id,
      'lastMessage': message.message,
      'members': FieldValue.arrayUnion([currentUser.uid]),
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
    return Right("ok");
  }
  
  @override
  Future<Either<dynamic, dynamic>> registerChat(ChatModel chat) async{
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Left("User not logged in");
    }
    DocumentReference<Map<String, dynamic>> chatRef = await FirebaseFirestore.instance.collection("chats").add({
      'lastReadTime': chat.lastReadTime,
      'lastSenderId': chat.lastSenderId,
      'messageId': chat.messageId,
      'members': FieldValue.arrayUnion(chat.members),
      'lastMessage': chat.lastMessage,
      'lastMessageTime': chat.lastMessageTime,
      'createdDate': FieldValue.serverTimestamp(),
    });
    chatRef.update({
      'chatId': chatRef.id,
    });
    return Right("ok");
  }
  
  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(String chatId) {
    return FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection("messages")
          .orderBy('createdTime', descending: false)
          .snapshots();
  }
  
  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> getChat(String chatId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .snapshots();
  } 
  @override
  Future<void> markChatAsRead(String chatId, String userId) async{
    try {
      final timestamp = DateTime.now().toIso8601String();
      final chatRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId);

      // Check if document exists first
      final doc = await chatRef.get();

      if (doc.exists) {
        // Document exists, update it
        await chatRef.update({
          'lastReadTime.${userId}': timestamp,
        });
      } else {
        // Document doesn't exist yet, create it with merge
        await chatRef.set({
          'lastReadTime': {
            userId: timestamp,
          },
        }, SetOptions(merge: true));
      }
    } catch (e) {
      // Silently fail - marking as read is not critical
      print('Error marking chat as read: $e');
    }
  }
}