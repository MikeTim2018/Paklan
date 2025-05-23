import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paklan/domain/auth/usecases/get_ages.dart';
import 'package:paklan/presentation/auth/bloc/ages_display_states.dart';
import 'package:paklan/service_locator.dart';

class AgesDisplayCubit  extends Cubit<AgesDisplayState>{
  AgesDisplayCubit(): super(AgesLoading());

  void displayAges() async{

    var returnedData = await sl<GetAgesUseCase>().call();

    returnedData.fold(
      (message){
        emit(
        AgesLoadFailure(message: message)
        );
      }
      , (data){
        emit(
        AgesLoaded(ages: data) 
        );
      });
  }

}