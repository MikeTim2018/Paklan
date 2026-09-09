
class MessageEntity {
  String message;
  String senderName;
  String senderId;
  String chatId;
  String messageId;
  String createdTime;

  MessageEntity({
    required this.message,
    required this.messageId,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.createdTime,
  });

}
