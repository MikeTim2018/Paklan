import 'package:packlan_alpha/core/usecase/usecase.dart';
import 'package:packlan_alpha/domain/auth/repository/auth.dart';
import 'package:packlan_alpha/service_locator.dart';

class IsLoggedInUseCase implements UseCase<bool, dynamic>{
  @override
  Future<bool> call({params}) async{
    return await sl<AuthRepository>().isLoggedIn();
  }

}