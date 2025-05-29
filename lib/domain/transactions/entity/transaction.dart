
class TransactionEntity {
  String ? amount ;
  String ? status;
  String ? sellerFirstName;
  String ? buyerFirstName;
  String ? transactionId;
  String ? statusId;

  TransactionEntity({
    required this.amount,
    required this.status,
    required this.sellerFirstName,
    required this.buyerFirstName,
    required this.transactionId,
    required this.statusId,
  });
}