
import 'dart:convert';
import 'package:paklan/domain/transactions/entity/transaction.dart';

class TransactionModel {
  String ? name;
  String ? amount;
  String ? status;
  String ? sellerDisplayName;
  String ? buyerDisplayName;
  String ? transactionId;
  String ? dealDetails;
  String ? typeOfProduct;
  String ? statusId;
  List<String> ? images;
  DateTime ? timeLimit;
  String ? fee;
  String ? sellerId;

  TransactionModel({
    required this.name,
    required this.amount,
    required this.status,
    required this.sellerDisplayName,
    required this.buyerDisplayName,
    required this.transactionId,
    required this.statusId,
    required this.typeOfProduct,
    required this.dealDetails,
    this.images,
    this.timeLimit,
    this.fee,
    this.sellerId,
  });


Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'amount': amount,
      'status': status,
      'sellerDisplayName': sellerDisplayName,
      'buyerDisplayName': buyerDisplayName,
      'transactionId': transactionId,
      'dealDetails': dealDetails,
      'typeOfProduct': typeOfProduct,
      'statusId': statusId,
      'images': images,
      'timeLimit': timeLimit,
      'fee': fee,
      'sellerId': sellerId,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      name: map['name'] as String,
      amount: map['amount'] as String,
      status: map['status'] as String,
      dealDetails: map['dealDetails'] as String,
      typeOfProduct: map['typeOfProduct'] as String,
      buyerDisplayName: map['members']['buyerDisplayName'] as String,
      sellerDisplayName: map['members']['sellerDisplayName'] as String, 
      transactionId: map['transactionId'] ?? '',
      statusId: map['statusId'] ?? '',
      timeLimit: map['timeLimit'].toDate() ?? DateTime.now().add(const Duration(hours: 24)).toUtc(),
      fee: map['fee'] ?? '0.00',
      images: List<String>.from(map['images'] ?? []),
      sellerId: map['members']['sellerId']
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
      buyerDisplayName: buyerDisplayName, 
      sellerDisplayName: sellerDisplayName,
      typeOfProduct: typeOfProduct,
      dealDetails: dealDetails,
      transactionId: transactionId,
      statusId: statusId,
      images: images,
      timeLimit: timeLimit,
      fee: fee,
      sellerId: sellerId,
    );
  }
}
