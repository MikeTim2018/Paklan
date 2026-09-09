
import 'dart:convert';
import 'package:paklan/domain/common/entity/chat.dart';


class ChatModel {
  String lastMessage;
  List lastReadTime;
  String lastSenderId;
  String chatId;
  String messageId;
  List members;
  String lastMessageTime;
  String createdDate;
  String ? transactionId;

  ChatModel({
    required this.lastMessage,
    required this.messageId,
    required this.chatId,
    required this.lastSenderId,
    required this.members,
    required this.lastReadTime,
    required this.lastMessageTime,
    required this.createdDate,
    this.transactionId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'lastMessage': lastMessage,
      'messageId': messageId,
      'chatId': chatId,
      'lastSenderId': lastSenderId,
      'members': members,
      'lastReadTime': lastReadTime,
      'lastMessageTime': lastMessageTime,
      'createdDate': createdDate,
      'transactionId': transactionId,
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      lastMessage: map['lastMessage'] ?? '',
      messageId: map['messageId'] ?? '',
      chatId: map['chatId'] ?? '',
      lastSenderId: map['lastSenderId'] ?? '',
      members: List<Map>.from(map['members'] as List<dynamic>),
      lastReadTime: List<Map>.from(map['lastReadTime'] as List<dynamic>),
      lastMessageTime: map['lastMessageTime'] ?? '',
      createdDate: map['createdDate'] ?? '',
      transactionId: map['transactionId'] ?? '',
    );
  }
  

  String toJson() => json.encode(toMap());

  factory ChatModel.fromJson(String source) => ChatModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

extension BuyerXModel on ChatModel {
  ChatEntity toEntity() {
    return ChatEntity(
      lastMessage: lastMessage,
      messageId: messageId,
      chatId: chatId,
      lastSenderId: lastSenderId,
      members: members,
      lastReadTime: lastReadTime,
      lastMessageTime: lastMessageTime,
      createdDate: createdDate,
      transactionId: transactionId
    );
  }
}
