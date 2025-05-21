import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paklan/common/bloc/transactions/transactions_display_state.dart';
import 'package:paklan/domain/transactions/usecases/get_transactions.dart';
import 'package:paklan/service_locator.dart';

class TransactionsDisplayCubit extends Cubit<TransactionsDisplayState> {
  TransactionsDisplayCubit(): super(TransactionsLoading());

  Future<void> displayTransactions() async {
    emit(TransactionsLoading());
    Either returnedData = await sl<GetTransactionsUseCase>().call();
    returnedData.fold(
      (error){
        emit(
          TransactionsLoadFailed(
            errorMessage: error)
        );
      }, 
      (data){
        if (data.length > 0){
          emit(
          TransactionsLoaded(
            transaction: data
          )
        );
        }
        else{
          emit(
            TransactionsEmpty()
          );
        }
        }
  );
  }
}