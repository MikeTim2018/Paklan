
import 'dart:convert';
import 'package:paklan/domain/transactions/entity/transaction.dart';

class TransactionModel {
  String ? amount;
  String ? status;
  String ? sellerFirstName;
  String ? buyerFirstName;

  TransactionModel({
    required this.amount,
    required this.status,
    required this.sellerFirstName,
    required this.buyerFirstName
  });


Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'amount': amount,
      'status': status,
      'sellerFirstName': sellerFirstName,
      'buyerFirstName': buyerFirstName,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      amount: map['amount'] as String,
      status: map['status'] as String,
      buyerFirstName: map['members']['buyerFirstName'] as String,
      sellerFirstName: map['members']['sellerFirstName'] as String,
    );
  }
  

  String toJson() => json.encode(toMap());

  factory TransactionModel.fromJson(String source) => TransactionModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

extension UserXModel on TransactionModel {
  TransactionEntity toEntity() {
    return TransactionEntity(
      amount: amount,
      status: status,
      buyerFirstName: buyerFirstName, 
      sellerFirstName: sellerFirstName,
    );
  }
}
