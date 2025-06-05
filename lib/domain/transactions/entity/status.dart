class StatusEntity {
  String ? status;
  String ? details;
  bool ? buyerConfirmation;
  bool ? sellerConfirmation;
  String ? transactionId;
  String ? buyerId;
  String ? sellerId;
  String ? currentUser;
  bool ? paymentDone;
  bool ? paymentTransferred;
  bool ? reimbursementDone;
  bool ? cancelled;
  String ? cancelledBy;

  StatusEntity({
  required this.status,
  required this.details,
  required this.buyerConfirmation,
  required this.sellerConfirmation,
  required this.transactionId,
  required this.sellerId,
  required this.buyerId,
  required this.cancelled,
  required this.currentUser,
  required this.paymentDone,
  required this.paymentTransferred,
  required this.reimbursementDone,
  this.cancelledBy,
  });
}