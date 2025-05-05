import 'package:dartz/dartz.dart';
import 'package:packlan_alpha/data/auth/models/user_creation_req.dart';
import 'package:packlan_alpha/data/auth/models/user_signin.dart';
import 'package:packlan_alpha/data/auth/source/auth_firebase_service.dart';
import 'package:packlan_alpha/domain/auth/repository/auth.dart';
import 'package:packlan_alpha/service_locator.dart';

class AuthRepositoryImpl extends AuthRepository{
  @override
  Future<Either> signup(UserCreationReq user) {
    return sl<AuthFirebaseService>().signup(user);
  }
  
  @override
  Future<Either> getAges() async{
    return await sl<AuthFirebaseService>().getAges();
  }

  @override
  Future<Either> signin(UserSigninReq user) async{
    return await sl<AuthFirebaseService>().signin(user);
  }
  
  @override
  Future<Either> sendPasswordResetEmail(String email) async{
    return await sl<AuthFirebaseService>().sendPasswordResetEmail(email);
  }
  
  @override
  Future<bool> isLoggedIn() async{
    return await sl<AuthFirebaseService>().isLoggedIn();
  }
  
  @override
  Future<Either> getUser() async{
    var user = await sl<AuthFirebaseService>().getUser();
    return user.fold(
      (error){
        return Left(error);
      }
      , (data){

      })
  }
}