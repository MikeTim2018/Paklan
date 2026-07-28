import 'package:dartz/dartz.dart';
import 'package:paklan/core/usecase/usecase.dart'; // import your StreamUseCase
import 'package:paklan/domain/auth/entity/user.dart';
import 'package:paklan/domain/auth/repository/auth.dart';
import 'package:paklan/service_locator.dart';

class GetUserUseCase implements StreamUseCase<Either<dynamic, UserEntity>, dynamic> {
  @override
  Stream<Either<dynamic, UserEntity>> call({dynamic params}) {
    return sl<AuthRepository>().getUser();
  }
}