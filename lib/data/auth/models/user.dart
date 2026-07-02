// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:paklan/domain/auth/entity/user.dart';


class UserModel {
  final String userId;
  final String displayName;
  final String firstName;
  final String lastName;
  final String email;
  final String image;
  final int gender;
  final String phone;
  final String phoneExt;
  final String photoLink;
  final bool clabe;

  UserModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    required this.email,
    required this.image,
    required this.gender,
    required this.phone,
    required this.phoneExt,
    required this.photoLink,
    required this.clabe,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'image': image,
      'gender': gender,
      'phone': phone,
      'phoneExt': phoneExt,
      'clabe': clabe,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      displayName: map['displayName'] as String,
      email: map['email'] as String,
      image: map['image'] ?? '',
      gender: map['gender'] ?? 1,
      phone: map['phone'] ?? '',
      phoneExt: map['phoneExt'] ?? '+52',
      photoLink: map['photoLink'] ?? '',
      clabe: map['CLABEs'] ?? false
    );
  }
  

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

extension UserXModel on UserModel {
  UserEntity toEntity() {
    return UserEntity(
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      displayName: displayName, 
      email: email, 
      image: image, 
      gender: gender,
      phone: "$phoneExt $phone",
      photoLink: photoLink,
      clabe: clabe,
    );
  }
}
