abstract class AppLifecycleState {}

class AppStateLoading extends AppLifecycleState {}

class AppStateInitial extends AppLifecycleState {}

class AppStateLoaded extends AppLifecycleState {}

class AppStateFailed extends AppLifecycleState {
  final String errorMessage;
  AppStateFailed({required this.errorMessage});
}
