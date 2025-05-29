import 'package:paklan/domain/transactions/entity/status.dart';

abstract class TransactionStateDisplayState {}

class TransactionLoaded extends TransactionStateDisplayState{ 
  final StatusEntity state;
  TransactionLoaded({required this.state});
 }

class TransactionLoading extends TransactionStateDisplayState{}

class TransactionFailure extends TransactionStateDisplayState{
  final String error;
  TransactionFailure({required this.error});
}

class TransactionInitial extends TransactionStateDisplayState{}