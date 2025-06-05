import 'package:flutter_bloc/flutter_bloc.dart';

class StepperSelectionCubit extends Cubit<int>{
  StepperSelectionCubit(): super(0);
  
  int selectedIndex = 0;

  void selectStep(int index){
    selectedIndex = index;
    emit(index);
  }

}