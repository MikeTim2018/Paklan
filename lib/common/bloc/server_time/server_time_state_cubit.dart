import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paklan/common/bloc/server_time/server_time_state.dart';
import 'package:paklan/domain/transactions/usecases/get_server_datetime.dart';
import 'package:paklan/service_locator.dart';

class ServerTimeStateCubit extends Cubit<ServerTimeState> {
  ServerTimeStateCubit() : super(ServerTimeLoadingState());


  Future<void> getServerTime() async{

    var returnedData = await sl<GetServerDatetimeUseCase>().call();

    returnedData.fold(
      (error){
        emit(
          ServerTimeFailureState(errorMessage: error.errorMessage)
        );
      }, 
      (data){
        emit(
          ServerTimeLoadedState(
            serverTime: data
          )
        );
      }
  );
  }
}
