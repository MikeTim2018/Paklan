import 'package:paklan/domain/transactions/entity/user.dart';

abstract class PersonInfoDisplayState {}

class PersonInfoLoaded extends PersonInfoDisplayState{ 
  final List<UserEntityTransaction> users;
  PersonInfoLoaded({required this.users});
 }

class PersonInfoLoading extends PersonInfoDisplayState{}

class LoadPersonInfoFailure extends PersonInfoDisplayState{
  final String error;
  LoadPersonInfoFailure({required this.error});
}

class PersonInfoEmpty extends PersonInfoDisplayState{}

class PersonInitialState extends PersonInfoDisplayState{}