abstract class ServerTimeState {}

class ServerTimeInitialState extends ServerTimeState {}

class ServerTimeLoadingState extends ServerTimeState {}

class ServerTimeLoadedState extends ServerTimeState {
  final String serverTime;
  ServerTimeLoadedState({required this.serverTime});
}

class ServerTimeFailureState extends ServerTimeState {
  final String errorMessage;
  ServerTimeFailureState({required this.errorMessage});
}
