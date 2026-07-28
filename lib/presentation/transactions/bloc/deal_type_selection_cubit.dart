import 'package:flutter_bloc/flutter_bloc.dart';

class DealTypeSelectionCubit extends Cubit<int>{
  DealTypeSelectionCubit(): super(1);
  
  int selectedIndex = 1;

  void selectUser(int index){
    selectedIndex = index;
    emit(index);
  }

}