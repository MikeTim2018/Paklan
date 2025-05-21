import 'package:paklan/core/usecase/usecase.dart';
import 'package:paklan/domain/auth/repository/auth.dart';
import 'package:paklan/service_locator.dart';

class IsLoggedInUseCase implements UseCase<bool, dynamic>{
  @override
  Future<bool> call({params}) async{
    return await sl<AuthRepository>().isLoggedIn();
  }

}