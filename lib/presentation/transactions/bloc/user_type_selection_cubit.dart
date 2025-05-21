import 'package:flutter_bloc/flutter_bloc.dart';

class UserTypeSelectionCubit extends Cubit<int>{
  UserTypeSelectionCubit(): super(1);
  
  int selectedIndex = 1;

  void selectUser(int index){
    selectedIndex = index;
    emit(index);
  }

}