import 'package:dartz/dartz.dart';
import 'package:paklan/core/usecase/usecase.dart';
import 'package:paklan/domain/payments/repository/payment.dart';
import 'package:paklan/service_locator.dart';

class PaymentOnboardingUsecase extends UseCase<Either,String> {
  @override
  Future <Either> call({String ? params}) async{
    return await sl<PaymentRepository>().startOnboarding(
      params!
    );
  }
}