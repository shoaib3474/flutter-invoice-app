abstract class BlocState {}

class InitialState extends BlocState {}

class LoadingState extends BlocState {}

class ErrorState extends BlocState {
  final String message;
  final dynamic error;

  ErrorState(this.message, [this.error]);
}
