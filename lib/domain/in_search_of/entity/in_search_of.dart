
import 'dart:io';

class InSearchOfEntity {
  String ? name;
  String ? transactionId;
  String ? reward;
  String ? status;
  String ? buyerDisplayName;
  String ? buyerId;
  String ? details;
  List<File> ? images;
  String ? typeOfProduct;
  String ? dealDetails;
  String ? typeOfDeal;
  List<String> ? imageUrls;
  String ? chatId;

  InSearchOfEntity({
    required this.name,
    required this.transactionId,
    required this.reward,
    required this.status,
    required this.buyerDisplayName,
    required this.buyerId,
    required this.details,
    required this.typeOfProduct,
    required this.images,
    required this.dealDetails,
    required this.typeOfDeal,
    this.imageUrls,
    this.chatId,
  });

}
