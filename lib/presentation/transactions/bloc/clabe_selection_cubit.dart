import 'package:flutter_bloc/flutter_bloc.dart';

class ClabeSelectionCubit extends Cubit<String>{

  ClabeSelectionCubit(): super ('CLABEs disponibles');

  String selectedClabe = '';

  void selectClabe(String clabe) {
    selectedClabe = clabe;
    emit(selectedClabe);
  }
}