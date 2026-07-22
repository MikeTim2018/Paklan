
class TransactionEntity {
  String ? name;
  String ? amount;
  String ? status;
  String ? sellerDisplayName;
  String ? buyerDisplayName;
  String ? transactionId;
  List<String> ? images;
  String ? dealDetails;
  String ? typeOfProduct;
  String ? statusId;
  DateTime ? timeLimit;
  String ? fee;
  String ? sellerId;

  TransactionEntity({
    required this.name,
    required this.amount,
    required this.status,
    required this.sellerDisplayName,
    required this.buyerDisplayName,
    required this.transactionId,
    required this.statusId,
    required this.images,
    required this.dealDetails,
    required this.typeOfProduct,
    this.timeLimit,
    this.fee,
    this.sellerId
  });
}