import 'dart:convert';

import 'package:paklan/domain/transactions/entity/status.dart';

class StatusModel {
  String ? status;
  String ? details;
  bool ? buyerConfirmation;
  bool ? sellerConfirmation;
  String ? transactionId;
  String ? buyerId;
  String ? sellerId;
  bool ? paymentDone;
  bool ? paymentTransferred;
  bool ? reimbursementDone;
  bool ? cancelled;
  String ? statusId;
  String ? cancelledBy;

  StatusModel({
  required this.status,
  required this.details,
  required this.buyerConfirmation,
  required this.sellerConfirmation,
  required this.transactionId,
  required this.buyerId,
  required this.sellerId,
  required this.paymentDone,
  required this.paymentTransferred,
  required this.reimbursementDone,
  required this.cancelled,
  this.statusId,
  this.cancelledBy,
  });

Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'status': status,
      'details': details,
      'buyerConfirmation': buyerConfirmation,
      'sellerConfirmation': sellerConfirmation,
      'transactionId': transactionId,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'paymentDone': paymentDone,
      'paymentTransferred': paymentTransferred,
      'reimbursementDone': reimbursementDone,
      'cancelled': cancelled,
      'cancelledBy': cancelledBy,
      'statusId': statusId,
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
      buyerId: map['buyerId'] as String, 
      sellerId: map['sellerId'] as String, 
      paymentDone: map['paymentDone'] as bool, 
      paymentTransferred: map['paymentTransferred'] as bool, 
      reimbursementDone: map['reimbursementDone'] as bool, 
      cancelled: map['cancelled'] as bool,
      statusId: map['statusId'] ?? '',
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
      buyerId: buyerId,
      sellerId: sellerId,
      cancelledBy: cancelledBy,
      cancelled: cancelled,
      paymentDone: paymentDone,
      paymentTransferred: paymentTransferred,
      reimbursementDone: reimbursementDone,
      statusId: statusId,
    );
  }
}