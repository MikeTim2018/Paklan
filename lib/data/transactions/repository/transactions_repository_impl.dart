import 'package:dartz/dartz.dart';
import 'package:paklan/data/transactions/models/new_transaction.dart';
import 'package:paklan/data/transactions/models/transaction.dart';
import 'package:paklan/data/transactions/models/user.dart';
import 'package:paklan/data/transactions/source/transaction_firebase_service.dart';
import 'package:paklan/domain/transactions/repository/transaction.dart';
import 'package:paklan/service_locator.dart';

class TransactionsRepositoryImpl extends TransactionRepository{
  @override
  Future<Either> getTransactions() async{
    Either transactions = await sl<TransactionFirebaseService>().getTransactions();
    return transactions.fold(
      (error){
        return Left(error);
      }, 
      (data){
        return Right(
          List.from(data).map((e) => TransactionModel.fromMap(e).toEntity()).toList()
          );
      }
      );
  }
  
  @override
  Future<Either> getPerson(String searchVal) async{
    Either transactions = await sl<TransactionFirebaseService>().getPerson(searchVal);
    return transactions.fold(
      (error){
        return Left(error);
      }, 
      (data){
        return Right(
          List.from(data).map((e) => UserModel.fromMap(e).toEntity()).toList()
          );
      }
      );
  }

  @override
  Future<Either> createTransaction(NewTransactionModel newTransaction) async{
    return await sl<TransactionFirebaseService>().createTransaction(newTransaction);
  }
}
