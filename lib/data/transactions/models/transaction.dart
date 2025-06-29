
import 'dart:convert';
import 'package:paklan/domain/transactions/entity/transaction.dart';

class TransactionModel {
  String ? name;
  String ? amount;
  String ? status;
  String ? sellerFirstName;
  String ? buyerFirstName;
  String ? transactionId;
  String ? statusId;
  DateTime ? timeLimit;

  TransactionModel({
    required this.name,
    required this.amount,
    required this.status,
    required this.sellerFirstName,
    required this.buyerFirstName,
    required this.transactionId,
    required this.statusId,
    this.timeLimit,
  });


Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'amount': amount,
      'status': status,
      'sellerFirstName': sellerFirstName,
      'buyerFirstName': buyerFirstName,
      'transactionId': transactionId,
      'statusId': statusId,
      'timeLimit': timeLimit,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      name: map['name'] as String,
      amount: map['amount'] as String,
      status: map['status'] as String,
      buyerFirstName: map['members']['buyerFirstName'] as String,
      sellerFirstName: map['members']['sellerFirstName'] as String, 
      transactionId: map['transactionId'] as String,
      statusId: map['statusId'] ?? '',
      timeLimit: map['timeLimit'].toDate() ?? DateTime.now().add(const Duration(hours: 24)).toUtc(),
    );
  }
  

  String toJson() => json.encode(toMap());

  factory TransactionModel.fromJson(String source) => TransactionModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

extension UserXModel on TransactionModel {
  TransactionEntity toEntity() {
    return TransactionEntity(
      name: name,
      amount: amount,
      status: status,
      buyerFirstName: buyerFirstName, 
      sellerFirstName: sellerFirstName,
      transactionId: transactionId,
      statusId: statusId,
      timeLimit: timeLimit
    );
  }
}
