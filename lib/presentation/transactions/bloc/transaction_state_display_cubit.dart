import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paklan/data/transactions/models/transaction.dart';
import 'package:paklan/domain/transactions/usecases/get_transaction.dart';
import 'package:paklan/presentation/transactions/bloc/transaction_state_display_state.dart';
import 'package:paklan/service_locator.dart';

class TransactionStateDisplayCubit extends Cubit<TransactionStateDisplayState> {
  TransactionStateDisplayCubit(): super(TransactionLoading());

  void getTransactionState({TransactionModel ? transaction}) async{
    emit(
      TransactionLoading()
    );

    var returnedData = await sl<GetTransactionUseCase>().call(params: transaction!);

    returnedData.fold(
      (error){
        emit(
          TransactionFailure(error: error)
        );
      }, 
      (data){
        emit(
          TransactionLoaded(
            state: data
          )
        );
      }
  );
  }
}