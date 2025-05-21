
class NewTransactionEntity {
  String ? amount;
  String ? status;
  String ? sellerFirstName;
  String ? buyerFirstName;
  String ? sellerId;
  String ? buyerId;
  String ? details;
  String ? buyerConfirmation;
  String ? sellerConfirmation;

  NewTransactionEntity({
    required this.amount,
    required this.status,
    required this.sellerFirstName,
    required this.buyerFirstName,
    required this.details,
  });
}