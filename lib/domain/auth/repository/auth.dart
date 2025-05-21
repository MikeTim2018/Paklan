import 'package:dartz/dartz.dart';
import 'package:paklan/data/auth/models/user_creation_req.dart';
import 'package:paklan/data/auth/models/user_signin.dart';

abstract class AuthRepository {
  
  Future<Either> signup(UserCreationReq user);
  Future<Either> getAges();
  Future<Either> signin(UserSigninReq user);
  Future<Either> sendPasswordResetEmail(String email);
  Future<bool> isLoggedIn();
  Future<Either> getUser();
}