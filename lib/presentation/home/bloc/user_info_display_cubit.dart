import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paklan/domain/auth/usecases/get_user.dart';
import 'package:paklan/presentation/home/bloc/user_info_display_state.dart';
import 'package:paklan/service_locator.dart';

class UserInfoDisplayCubit extends Cubit<UserInfoDisplayState> {
  UserInfoDisplayCubit() : super(UserInfoLoading());

  StreamSubscription? _userSubscription;

  void displayUserInfo() async{
    emit(UserInfoLoading());
    _userSubscription?.cancel();

    _userSubscription = sl<GetUserUseCase>().call().listen(
      (either) {
        either.fold(
          (failure) => emit(LoadUserInfoFailure()),
          (user) => emit(UserInfoLoaded(user: user)),
        );
      },
    );
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}