import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paklan/common/bloc/app_lifecycle/app_lifecycle_state.dart';
import 'package:paklan/domain/common/usecases/register_app_state.dart';
import 'package:paklan/service_locator.dart';



class AppLifecycleCubit extends Cubit<AppLifecycleState> {
  AppLifecycleCubit() : super(AppStateInitial());


  Future<void> registerState({bool ? active}) async {
    emit(AppStateLoading());
    try {
      Either returnedData = await sl<RegisterAppStateUseCase>().call(params: active);
      if (isClosed) return;
      returnedData.fold(
        (error) {
          emit(
            AppStateFailed(
            errorMessage: error
          )
         );
        },
        (data) {
          emit(AppStateLoaded());
        }
      );

    } catch (e) {
      if (isClosed) return;
      emit(
        AppStateFailed(
          errorMessage: e.toString()
        )
      );
    }
  }
}
