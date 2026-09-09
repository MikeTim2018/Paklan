import 'package:dartz/dartz.dart';

abstract class PaymentRepository {
  Future<Either> startOnboarding(String email);
}