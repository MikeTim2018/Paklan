class StatusEntity {
  String ? status;
  String ? details;
  bool ? buyerConfirmation;
  bool ? sellerConfirmation;
  String ? transactionId;
  String ? cancelledBy;

  StatusEntity({
  required this.status,
  required this.details,
  required this.buyerConfirmation,
  required this.sellerConfirmation,
  required this.transactionId,
  this.cancelledBy,
  });
}