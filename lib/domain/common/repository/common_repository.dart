import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:paklan/data/common/models/chat.dart';
import 'package:paklan/data/common/models/message.dart';

abstract class CommonRepository {
  Future<Either> registerAppState(bool active);
  Stream<DocumentSnapshot<Map<String, dynamic>>> getBuyerProfileStream(String buyerId);
  Stream<DocumentSnapshot<Map<String, dynamic>>> getSellerProfileStream(String sellerId);
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserProfileStream(String userId);
  Future<Either> registerMessage(MessageModel message);
  Future<Either> registerChat(ChatModel message);
  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(String chatId);
  Stream<DocumentSnapshot<Map<String, dynamic>>> getchat(String chatId);
  Future<void> markChatAsRead(String chatId, String userId);
}