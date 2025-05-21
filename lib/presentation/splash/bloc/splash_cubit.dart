import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paklan/domain/auth/usecases/is_logged_in.dart';
import 'package:paklan/presentation/splash/bloc/splash_state.dart';
import 'package:paklan/service_locator.dart';

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