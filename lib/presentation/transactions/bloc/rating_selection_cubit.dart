import 'package:flutter_bloc/flutter_bloc.dart';

class RatingSelectionCubit extends Cubit<double>{
  RatingSelectionCubit(): super(3.0);
  
  double selectedIndex = 3.0;

  void selectRating(double index){
    selectedIndex = index;
    emit(index);
  }

}