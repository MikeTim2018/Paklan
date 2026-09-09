import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';

abstract class PaymentFirebaseService {
  Future<Either<dynamic, dynamic>> fetchOnboardingUrl({
    required String email,
  });
}

class PaymentFirebaseServiceImpl extends PaymentFirebaseService {

  @override
  Future<Either<dynamic, dynamic>> fetchOnboardingUrl({
    required String email,
  }) async {
    try{
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('create_connect_account');
    HttpsCallableResult result = await callable.call(<String, dynamic>{
      'email': email,
    });
      final data = result.data as Map<String, dynamic>; 
      
      if (data.containsKey('url')) {
        return Right(data['url'] as String);
      }
      return const Left("Response payload missing 'url' key");

    } on FirebaseFunctionsException catch (e) {
      return Left("Firebase Error [${e.code}]: ${e.message}");
    } catch (e) {
      return Left("Unexpected error: ${e.toString()}");
    }
}
}