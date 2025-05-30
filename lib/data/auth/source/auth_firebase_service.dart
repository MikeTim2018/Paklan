import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:paklan/data/auth/models/user_creation_req.dart';
import 'package:paklan/data/auth/models/user_signin.dart';

abstract class AuthFirebaseService {
  Future<Either> signup(UserCreationReq user);
  Future<Either> getAges();
  Future<Either> signin(UserSigninReq user);
  Future<Either> sendPasswordResetEmail(String email);
  Future<bool> isLoggedIn();
  Future<Either> getUser();
  Future <void> saveTokenToDatabase(String token);
  Future <void> setupToken();
}

class AuthFirebaseServiceImpl extends AuthFirebaseService{

  @override
  Future<Either> signup(UserCreationReq user) async{
    try {
      var returnedData = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: user.email!,
        password: user.password!);

        await FirebaseFirestore.instance.collection('users').doc(
          returnedData.user!.uid
        ).set(
          {
            'firstName': user.firstName,
            'lastName': user.lastName,
            'email': user.email,
            'gender': user.gender,
            'age': user.age,
            'phone': user.phone!.substring(3),
            'phoneExt': user.phone!.substring(0, 3),
            'userId': returnedData.user!.uid
          }
        );
        await setupToken();
        return Right('Signup was Successful!');
    }on FirebaseAuthException catch(e){

      String message = '';
      if (e.code == 'weak-password'){
        message = 'La contraseña debe ser mayor a 6 caracteres.';
      } else if(e.code == 'email-already-in-use'){
        message = 'Una cuenta ya ha sido creada con este Email.';
      }
      else{
        message = "${e.code}: Ocurrió un error porfavor intenta de nuevo.";
      }
      return Left(message);
    }
  }
  
  @override
  Future<Either> getAges() async{
    try{
      var returnedData = await FirebaseFirestore.instance.collection('ages').get();
      List<QueryDocumentSnapshot<Map<String, dynamic>>> returnedListData = returnedData.docs;
      returnedListData.sort((a, b) => a.data()['index'].compareTo(b.data()['index']),);
      return Right(returnedListData);
    }catch(e){
      return Left(
        "Por favor intenta más tarde"
      );
    }
  }
  
  @override
  Future<Either> signin(UserSigninReq user) async{
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: user.email!,
        password: user.password!);
      await setupToken();
      return Right('Signup was Successful!');
    }on FirebaseAuthException catch(e){

      String message = '';
      if (e.code == 'invalid-password' || e.code == 'invalid-credential'){
        message = 'La contraseña ingresada es incorrecta. Intenta de nuevo.';
      } else if(e.code == 'user-not-found'){
        message = 'No se encontró ningún usuario.';
      } else if (e.code == 'invalid-email'){
        message = 'Email ingresado es incorrecto. Intenta de nuevo.';
      }
      else{
        message = "${e.code}: Ocurrió un error porfavor intenta de nuevo.}";
      }
      return Left(message);
    }
  }
  
  @override
  Future<Either> sendPasswordResetEmail(String email) async{
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email);
      return const Right("La contraseña ha sido enviada al correo registrado!");
    } on FirebaseAuthException catch(e){
      String message = '';
      if (e.code == ''){
        message = "Ha ocurrido un error, Intenta de nuevo!";
      }
      else {
        message = e.toString();
      }
      return Left(message);
    }
  }
  
  @override
  Future<bool> isLoggedIn() async{
    if (FirebaseAuth.instance.currentUser != null){
      await setupToken();
      return true;
    }
    else{
      return false;
    }
  }
  
  @override
  Future<Either> getUser() async{
    try{
      var currentUser = FirebaseAuth.instance.currentUser;
      var userData = await FirebaseFirestore.instance.collection("users").doc(
        currentUser?.uid
      ).get().then((value) => value.data());
      return Right(userData);
    }catch(e){
      return Left(
        "Porfavor intenta más tarde"
      );
    }
  }
  
  @override
  Future<void> saveTokenToDatabase(String token) async{
    var userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .update({
      'tokens': FieldValue.arrayUnion([token]),
    });
  }
  
  @override
  Future<void> setupToken() async {
    final notificationSettings = await FirebaseMessaging.instance.requestPermission();
    if (notificationSettings.authorizationStatus == AuthorizationStatus.denied || 
        notificationSettings.authorizationStatus ==AuthorizationStatus.notDetermined){
      return;
    }

    // Get the token each time the application loads
    String? token = await FirebaseMessaging.instance.getToken();

    // Save the initial token to the database
    await saveTokenToDatabase(token!);

    // Any time the token refreshes, store this in the database too.
    FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);
  }

}