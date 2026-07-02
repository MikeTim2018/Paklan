abstract class GoogleButtonState {}

class GoogleButtonInitialState extends GoogleButtonState {}

class GoogleButtonLoadingState extends GoogleButtonState {}

class GoogleButtonSuccessState extends GoogleButtonState {}

class GoogleButtonFailureState extends GoogleButtonState {
  final String errorMessage;
  GoogleButtonFailureState({required this.errorMessage});
}
