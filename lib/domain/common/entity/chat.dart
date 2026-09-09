
class ChatEntity {
  String lastMessage;
  List lastReadTime;
  String lastSenderId;
  String chatId;
  String messageId;
  List members;
  String lastMessageTime;
  String createdDate;
  String ? transactionId;

  ChatEntity({
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

}
