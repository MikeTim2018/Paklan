import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:paklan/data/common/models/chat.dart';
import 'package:paklan/data/common/models/message.dart';
import 'package:paklan/data/common/source/common_service.dart';
import 'package:paklan/domain/common/repository/common_repository.dart';
import 'package:paklan/service_locator.dart';

class CommonRepositoryImpl extends CommonRepository{
  
  @override
  Future<Either<dynamic, dynamic>> registerAppState(active) async{
    return await sl<CommonService>().registerAppState(active);
  }

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> getBuyerProfileStream(String buyerId) {
    return sl<CommonService>().getBuyerProfileStream(buyerId);
  }

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserProfileStream(String buyerId) {
    return sl<CommonService>().getUserProfileStream(buyerId);
  }

  @override
  Future<Either<dynamic, dynamic>> registerMessage(MessageModel message) {
    return sl<CommonService>().registerMessage(message);
  }
  
  @override
  Future<Either<dynamic, dynamic>> registerChat(ChatModel message) {
    return sl<CommonService>().registerChat(message);
  }
  
  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(String chatId) {
    return sl<CommonService>().getMessages(chatId);
  }

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> getchat(String chatId) {
    return sl<CommonService>().getChat(chatId);
  }
  
  @override
  Future<void> markChatAsRead(String chatId, String userId) async {
    return await sl<CommonService>().markChatAsRead(chatId, userId);
  }


}
