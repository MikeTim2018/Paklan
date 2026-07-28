import 'package:dartz/dartz.dart';
import 'package:paklan/data/auth/models/user_creation_req.dart';
import 'package:paklan/data/auth/models/user_signin.dart';
import 'package:paklan/domain/auth/entity/user.dart';

abstract class AuthRepository {
  
  Future<Either> signup(UserCreationReq user);
  Future<Either> getAges();
  Future<Either> signin(UserSigninReq user);
  Future<Either> sendPasswordResetEmail(String email);
  Future<bool> isLoggedIn();
  Stream<Either<dynamic, UserEntity>> getUser();
  Future<Either> signout();
  Future<Either> signInWithGoogle();
  Future<Either> signInWithFacebook();
}