
import 'dart:io';

class NewTransactionModel {
  String ? name;
  String ? amount;
  String ? status;
  String ? sellerDisplayName;
  String ? buyerDisplayName;
  String ? sellerId;
  String ? buyerId;
  String ? details;
  List<File> ? images;
  bool ? buyerConfirmation;
  bool ? sellerConfirmation;
  String ? typeOfProduct;
  String ? dealDetails;

  NewTransactionModel({
    required this.name,
    required this.amount,
    required this.status,
    required this.sellerDisplayName,
    required this.buyerDisplayName,
    required this.sellerId,
    required this.buyerId,
    required this.details,
    required this.buyerConfirmation,
    required this.sellerConfirmation,
    required this.typeOfProduct,
    required this.images,
    required this.dealDetails
  });

}

