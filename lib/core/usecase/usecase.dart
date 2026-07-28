// core/usecase/usecase.dart

// Standard Future UseCase
abstract class UseCase<Type, Params> {
  Future<Type> call({Params params});
}

// Dedicated Stream UseCase
abstract class StreamUseCase<Type, Params> {
  Stream<Type> call({Params params});
}