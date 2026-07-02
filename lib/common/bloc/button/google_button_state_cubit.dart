import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paklan/common/bloc/button/google_button_state.dart';

import '../../../core/usecase/usecase.dart';

class GoogleButtonStateCubit extends Cubit<GoogleButtonState> {
  GoogleButtonStateCubit() : super(GoogleButtonInitialState());


  Future<void> execute({dynamic params,required UseCase usecase }) async {
    emit(GoogleButtonLoadingState());
    try {
      Either returnedData = await usecase.call(params: params);
      returnedData.fold(
        (error) {
          emit(
            GoogleButtonFailureState(
            errorMessage: error
          )
         );
        },
        (data) {
          emit(GoogleButtonSuccessState());
        }
      );

    } catch (e) {
      emit(
        GoogleButtonFailureState(
          errorMessage: e.toString()
        )
      );
    }
  }
}
