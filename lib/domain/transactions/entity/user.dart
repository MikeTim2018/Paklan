class UserEntityTransaction {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String image;
  final String phone;
  final String displayName;
  final int notificationNumber;

  UserEntityTransaction({
    required this.userId,
    required this.displayName,
    required this.email,
    required this.image,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.notificationNumber
  });
}