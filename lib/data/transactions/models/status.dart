import 'dart:convert';

import 'package:paklan/domain/transactions/entity/status.dart';

class StatusModel {
  String ? status;
  String ? details;
  bool ? buyerConfirmation;
  bool ? sellerConfirmation;
  String ? transactionId;
  String ? cancelledBy;

  StatusModel({
  required this.status,
  required this.details,
  required this.buyerConfirmation,
  required this.sellerConfirmation,
  required this.transactionId,
  this.cancelledBy,
  });

Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'status': status,
      'details': details,
      'buyerConfirmation': buyerConfirmation,
      'sellerConfirmation': sellerConfirmation,
      'transactionId': transactionId,
      'cancelledBy': cancelledBy,
    };
  }

  factory StatusModel.fromMap(Map<String, dynamic> map) {
    return StatusModel(
      details: map['details'] as String,
      status: map['status'] as String,
      buyerConfirmation: map['buyerConfirmation'] as bool,
      sellerConfirmation: map['sellerConfirmation'] as bool,
      transactionId: map['transactionId'] as String,
      cancelledBy: map['cancelledBy'] ?? '',
    );
  }
  

  String toJson() => json.encode(toMap());

  factory StatusModel.fromJson(String source) => StatusModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

extension UserXModel on StatusModel {
  StatusEntity toEntity() {
    return StatusEntity(
      details: details,
      status: status,
      buyerConfirmation: buyerConfirmation, 
      sellerConfirmation: sellerConfirmation,
      transactionId: transactionId,
      cancelledBy: cancelledBy
    );
  }
}