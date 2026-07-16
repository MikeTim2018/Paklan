// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:paklan/domain/transactions/entity/user.dart';



class UserModel {
  final String userId;
  final String displayName;
  final String firstName;
  final String lastName;
  final String email;
  final String image;
  final String phone;
  final String phoneExt;
  final int notificationNumber;


  UserModel({
    required this.userId,
    required this.displayName,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.image,
    required this.phone,
    required this.phoneExt,
    required this.notificationNumber,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'image': image,
      'phone': phone,
      'phoneExt': phoneExt,
      'displayName': displayName,
      'notificationNumber': notificationNumber,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ??  '',
      displayName: map['displayName'] as String,
      email: map['email'] as String,
      image: map['image'] ?? '',
      phone: map['phone'] ?? '',
      phoneExt: map['phoneExt'] ?? '+52',
      notificationNumber: map['notificationNumber'] ?? 0
    );
  }
  

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

extension UserXModel on UserModel {
  UserEntityTransaction toEntity() {
    return UserEntityTransaction(
      userId: userId,
      displayName: displayName,
      firstName: firstName,
      lastName: lastName, 
      email: email, 
      image: image,
      phone: "$phoneExt $phone",
      notificationNumber: notificationNumber
    );
  }
}
