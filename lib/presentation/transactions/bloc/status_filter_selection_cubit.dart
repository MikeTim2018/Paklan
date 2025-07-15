import 'package:flutter_bloc/flutter_bloc.dart';

class StatusFilterSelectionCubit extends Cubit<List<String>>{

  StatusFilterSelectionCubit(): super ([]);

  List<String> selectedFilters = ["Aceptado", "Depositado", "Enviado"];

  void selectFilters(List<String> filters) {
    selectedFilters = filters;
    emit(selectedFilters);
  }
}