import 'package:flutter_bloc/flutter_bloc.dart';

// Bottom Navigation Bar Cubit
class BottomNavCubit extends Cubit<int> {
  BottomNavCubit() : super(0);

  void changeSelectedIndex(int newIndex) => emit(newIndex);
}