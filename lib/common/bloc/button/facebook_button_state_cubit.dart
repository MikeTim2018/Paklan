import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paklan/common/bloc/button/facebook_button_state.dart';

import '../../../core/usecase/usecase.dart';

class FacebookButtonStateCubit extends Cubit<FacebookButtonState> {
  FacebookButtonStateCubit() : super(FacebookButtonInitialState());


  Future<void> execute({dynamic params,required UseCase usecase }) async {
    emit(FacebookButtonLoadingState());
    try {
      Either returnedData = await usecase.call(params: params);
      returnedData.fold(
        (error) {
          emit(
            FacebookButtonFailureState(
            errorMessage: error
          )
         );
        },
        (data) {
          emit(FacebookButtonSuccessState());
        }
      );

    } catch (e) {
      emit(
        FacebookButtonFailureState(
          errorMessage: e.toString()
        )
      );
    }
  }
}
