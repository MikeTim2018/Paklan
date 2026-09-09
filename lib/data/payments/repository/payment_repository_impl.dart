import 'package:dartz/dartz.dart';
import 'package:paklan/data/payments/source/payment_firebase_service.dart';
import 'package:paklan/domain/payments/repository/payment.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:paklan/service_locator.dart';

class PaymentRepositoryImpl extends PaymentRepository {
  @override
  Future<Either<dynamic, dynamic>> startOnboarding(String email) async{
    {
    try {
      // 1. Fetch the URL from the data source
      final Either<dynamic, dynamic> result = await sl<PaymentFirebaseService>().fetchOnboardingUrl(
        email: email,
      );
      // 2. Unfold the result and act accordingly
    return result.fold(
      (errorMessage) {
        // Data layer returned an error, pass it to the Left
        return Left(errorMessage);
      },
      (urlString) async {
        try {
          final Uri url = Uri.parse(urlString);
          
          // Launch the web browser natively
          final bool launchSuccess = await launchUrl(
            url,
            mode: LaunchMode.externalApplication,
          );

          if (launchSuccess) {
            return const Right(unit);
          } else {
            return Left("Could not open external browser for $urlString");
          }
        } catch (e) {
          return Left("Failed to parse or launch onboarding URL: ${e.toString()}");
        }
      },
    );
      
    } catch (e) {
      // Re-throw or map to custom domain-specific errors
      return Left("Onboarding failed: $e");
    }
    }
  }

  
}
