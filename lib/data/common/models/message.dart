
import 'dart:convert';
import 'package:paklan/domain/common/entity/message.dart';

class MessageModel {
  final String message;
  final String senderName;
  final String senderId;
  final String chatId;
  final String messageId;
  final String createdTime;
  

  MessageModel({
    required this.message,
    required this.messageId,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.createdTime,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'message': message,
      'messageId': messageId,
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'createdTime': createdTime,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      message: map['message'] ?? '',
      messageId: map['messageId'] ?? '',
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      createdTime: map['createdTime'] ?? '',
    );
  }
  

  String toJson() => json.encode(toMap());

  factory MessageModel.fromJson(String source) => MessageModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

extension BuyerXModel on MessageModel {
  MessageEntity toEntity() {
    return MessageEntity(
      message: message,
      messageId: messageId,
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      createdTime: createdTime,
    );
  }
}
