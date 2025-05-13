part of 'loggers_cubit.dart';

class LoggersState{
  final Failure? failure;
  final bool loading;
  final int? statusCode;
  final String? message;

  //? Model Area
  final LoggersBase? responseModel;

  const LoggersState({
    this.failure,
    this.loading = false,

    //? Model Area
    this.message,
    this.statusCode,
    this.responseModel,
  });

  LoggersState requestSuccess(LoggersBase response) => copyWith(
        loading: false,
        //? Model Area
        statusCode: 200,
        message: "OK",
        responseModel: Nullable(response),
      );

  LoggersState requestFailed(Failure failure) {
    if (failure is ErrorFailure) {
      return copyWith(
        statusCode: failure.error.statusCode,
        message: failure.error.message,
        loading: false,
        responseModel: Nullable(null),
        failure: Nullable(failure),
      );
    }
    return copyWith(
      loading: false,
      responseModel: Nullable(null),
      failure: Nullable(failure),
    );
  }

  LoggersState requestLoading() => copyWith(
        loading: true,
        statusCode: 0,
        responseModel: Nullable(null),
        failure: Nullable(null),
      );

  LoggersState copyWith(
      {Nullable<Failure?>? failure,
      bool? loading,

      //? Model Area
      int? statusCode,
      String? message,
      Nullable<LoggersBase?>? responseModel}) {
    return LoggersState(
      failure: failure == null ? this.failure : failure.value,
      loading: loading ?? this.loading,

      //? Model Area
      statusCode: statusCode ?? 0,
      message: message,
      responseModel:
          responseModel == null ? this.responseModel : responseModel.value,
    );
  }
}
class LoggersStateInitial extends LoggersState {}
