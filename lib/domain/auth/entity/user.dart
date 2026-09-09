import 'package:cloud_firestore/cloud_firestore.dart';

class UserEntity {
  final String userId;
  final String firstName;
  final String displayName;
  final String lastName;
  final String email;
  final String image;
  final int gender;
  final String phone;
  final String photoLink;
  final bool clabe;
  final int notificationNumber;
  final bool active;
  final Timestamp lastActive;

  UserEntity({
    required this.userId,
    required this.firstName,
    required this.displayName,
    required this.lastName,
    required this.email,
    required this.image,
    required this.gender,
    required this.photoLink,
    required this.phone,
    required this.clabe,
    required this.notificationNumber,
    required this.active,
    required this.lastActive
  });
}