
import 'dart:convert';
import 'package:paklan/domain/common/entity/seller.dart';

class SellerModel {
  final int totalRatingSum;
  final int totalRatingCount;
  final double averageRating;
  final String lastRatingMessage;
  final String updatedDate;
  final String transactionId;
  

  SellerModel({
    required this.totalRatingSum,
    required this.transactionId,
    required this.totalRatingCount,
    required this.averageRating,
    required this.lastRatingMessage,
    required this.updatedDate,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'totalRatingSum': totalRatingSum,
      'transactionId': transactionId,
      'totalRatingCount': totalRatingCount,
      'averageRating': averageRating,
      'lastRatingMessage': lastRatingMessage,
      'updatedDate': updatedDate,
    };
  }

  factory SellerModel.fromMap(Map<String, dynamic> map) {
    return SellerModel(
      totalRatingSum: map['totalRatingSum'] ?? 0,
      transactionId: map['transactionId'] ?? '',
      totalRatingCount: map['totalRatingCount'] ?? 0,
      averageRating: map['averageRating'] ?? 0.0,
      lastRatingMessage: map['lastRatingMessage'] ?? '',
      updatedDate: map['updatedDate'] ?? ''
    );
  }
  

  String toJson() => json.encode(toMap());

  factory SellerModel.fromJson(String source) => SellerModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

extension BuyerXModel on SellerModel {
  SellerEntity toEntity() {
    return SellerEntity(
      totalRatingSum: totalRatingSum,
      transactionId: transactionId,
      totalRatingCount: totalRatingCount,
      averageRating: averageRating,
      lastRatingMessage: lastRatingMessage,
      updatedDate: updatedDate
    );
  }
}
