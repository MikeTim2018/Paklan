
class TransactionEntity {
  String ? name;
  String ? amount;
  String ? status;
  String ? sellerFirstName;
  String ? buyerFirstName;
  String ? transactionId;
  String ? statusId;
  DateTime ? timeLimit;
  String ? fee;

  TransactionEntity({
    required this.name,
    required this.amount,
    required this.status,
    required this.sellerFirstName,
    required this.buyerFirstName,
    required this.transactionId,
    required this.statusId,
    this.timeLimit,
    this.fee,
  });
}