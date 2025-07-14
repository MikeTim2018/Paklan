import 'package:flutter_bloc/flutter_bloc.dart';

class StatusFilterHistorySelectionCubit extends Cubit<List<String>>{

  StatusFilterHistorySelectionCubit(): super (["Completado", "Cancelado"]);

  List<String> selectedFilters = ["Completado", "Cancelado"];

  void selectFilters(List<String> filters) {
    selectedFilters = filters;
    emit(selectedFilters);
  }
}