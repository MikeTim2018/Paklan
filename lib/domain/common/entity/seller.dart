
class SellerEntity {
  int totalRatingSum;
  int totalRatingCount;
  double averageRating;
  String lastRatingMessage;
  String updatedDate;
  String transactionId;

  SellerEntity({
    required this.totalRatingSum,
    required this.transactionId,
    required this.totalRatingCount,
    required this.averageRating,
    required this.lastRatingMessage,
    required this.updatedDate,
  });

}
