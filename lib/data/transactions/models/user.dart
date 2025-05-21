// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:paklan/domain/transactions/entity/user.dart';



class UserModel {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String image;
  final String phone;


  UserModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.image,
    required this.phone
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'image': image,
      'phone': phone,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      email: map['email'] as String,
      image: map['image'] ?? '',
      phone: map['phone'] ?? '',
    );
  }
  

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

extension UserXModel on UserModel {
  UserEntityTransaction toEntity() {
    return UserEntityTransaction(
      userId: userId,
      firstName: firstName,
      lastName: lastName, 
      email: email, 
      image: image,
      phone: phone
    );
  }
}
