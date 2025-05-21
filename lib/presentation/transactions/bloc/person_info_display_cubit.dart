import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paklan/domain/transactions/usecases/get_users_by_search.dart';
import 'package:paklan/presentation/transactions/bloc/person_info_display_state.dart';
import 'package:paklan/service_locator.dart';

class PersonInfoDisplayCubit extends Cubit<PersonInfoDisplayState> {
  PersonInfoDisplayCubit(): super(PersonInitialState());

  void findPerson({String ? searchVal}) async{
    emit(
      PersonInfoLoading()
    );

    var returnedData = await sl<GetUsersBySearchUseCase>().call(params: searchVal!);

    returnedData.fold(
      (error){
        emit(
          LoadPersonInfoFailure(error: error)
        );
      }, 
      (data){
        if (data.length == 0){
          emit(PersonInfoEmpty());
        }
        else{
        emit(
          PersonInfoLoaded(
            users: data
          )
        );
        }
      }
  );
  }
}