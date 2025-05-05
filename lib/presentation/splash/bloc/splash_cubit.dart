import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:packlan_alpha/domain/auth/usecases/is_logged_in.dart';
import 'package:packlan_alpha/presentation/splash/bloc/splash_state.dart';
import 'package:packlan_alpha/service_locator.dart';

class SplashCubit extends Cubit<SplashState> {

  SplashCubit(): super(DisplaySplash());

  void appStarted() async{
    await Future.delayed(Duration(seconds: 2));
    var isLoggedIn = await sl<IsLoggedInUseCase>().call();
    if (isLoggedIn){
      emit(Authenticated());
    }else {
    emit(
      UnAuthenticated()
    );
    }
  }
}