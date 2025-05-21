
class TransactionEntity {
  String ? amount ;
  String ? status;
  String ? sellerFirstName;
  String ? buyerFirstName;

  TransactionEntity({
    required this.amount,
    required this.status,
    required this.sellerFirstName,
    required this.buyerFirstName
  });
}