import 'package:paklan/domain/transactions/entity/transaction.dart';

abstract class TransactionsDisplayState {}

class TransactionsLoading extends TransactionsDisplayState{}

class TransactionsLoaded extends TransactionsDisplayState{
  final List<TransactionEntity> transaction;
  TransactionsLoaded({required this.transaction});
}

class TransactionsEmpty extends TransactionsDisplayState{}

class TransactionsLoadFailed extends TransactionsDisplayState{
  final String errorMessage;
  TransactionsLoadFailed({required this.errorMessage});
}