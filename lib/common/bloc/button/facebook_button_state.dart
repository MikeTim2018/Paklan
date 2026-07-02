abstract class FacebookButtonState {}

class FacebookButtonInitialState extends FacebookButtonState {}

class FacebookButtonLoadingState extends FacebookButtonState {}

class FacebookButtonSuccessState extends FacebookButtonState {}

class FacebookButtonFailureState extends FacebookButtonState {
  final String errorMessage;
  FacebookButtonFailureState({required this.errorMessage});
}
