
class NewTransactionModel {
  String ? name;
  String ? amount;
  String ? status;
  String ? sellerFirstName;
  String ? buyerFirstName;
  String ? sellerId;
  String ? buyerId;
  String ? details;
  bool ? buyerConfirmation;
  bool ? sellerConfirmation;
  String ? clabe;

  NewTransactionModel({
    required this.name,
    required this.amount,
    required this.status,
    required this.sellerFirstName,
    required this.buyerFirstName,
    required this.sellerId,
    required this.buyerId,
    required this.details,
    required this.buyerConfirmation,
    required this.sellerConfirmation,
    required this.clabe
  });

}

