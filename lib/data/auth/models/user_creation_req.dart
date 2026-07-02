class UserCreationReq {
  String ? displayName;
  String ? email;
  String ? password;

  UserCreationReq({
    required this.displayName,
    required this.email,
    required this.password,
  });
}