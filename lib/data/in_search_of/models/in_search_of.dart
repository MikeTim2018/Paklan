
import 'dart:convert';
import 'dart:io';

import 'package:paklan/domain/in_search_of/entity/in_search_of.dart';

class InSearchOfModel {
  String ? name;
  String ? transactionId;
  String ? reward;
  String ? status;
  String ? buyerDisplayName;
  String ? buyerId;
  String ? details;
  List<File> ? images;
  List<String> ? imageUrls;
  String ? typeOfProduct;
  String ? dealDetails;
  String ? typeOfDeal;
  String ? chatId;

  InSearchOfModel({
    required this.name,
    required this.reward,
    required this.status,
    required this.buyerDisplayName,
    required this.buyerId,
    required this.details,
    required this.typeOfProduct,
    required this.images,
    required this.dealDetails,
    required this.typeOfDeal,
    this.transactionId,
    this.chatId,
    this.imageUrls
  });

Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'transactionId': transactionId,
      'reward': reward,
      'status': status,
      'buyerDisplayName': buyerDisplayName,
      'buyerId': buyerId,
      'details': details,
      'dealDetails': dealDetails,
      'typeOfProduct': typeOfProduct,
      'imageUrls': imageUrls,
      'typeOfDeal': typeOfDeal,
      'chatId': chatId,
    };
  }

  factory InSearchOfModel.fromMap(Map<String, dynamic> map) {
    return InSearchOfModel(
      name: map['name'] as String,
      reward: map['reward'] ?? '????',
      transactionId: map['transactionId'] ?? '',
      status: map['status'] as String,
      details: map['details'] ?? '',
      buyerId: map['buyerId'] ?? '',
      images:  List<File>.empty(),
      dealDetails: map['dealDetails'] as String,
      typeOfProduct: map['typeOfProduct'] as String,
      buyerDisplayName: map['buyerDisplayName'] ?? '?????',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      typeOfDeal: map['typeOfDeal'] as String,
      chatId: map['chatId'] as String?,
    );
  }
  

  String toJson() => json.encode(toMap());

  factory InSearchOfModel.fromJson(String source) => InSearchOfModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

extension UserXModel on InSearchOfModel {
  InSearchOfEntity toEntity() {
    return InSearchOfEntity(
      name: name,
      transactionId: transactionId,
      reward: reward,
      details: details,
      buyerId: buyerId,
      status: status,
      buyerDisplayName: buyerDisplayName, 
      typeOfProduct: typeOfProduct,
      dealDetails: dealDetails,
      images: images,
      imageUrls: imageUrls,
      typeOfDeal: typeOfDeal,
      chatId: chatId
    );
  }
}
