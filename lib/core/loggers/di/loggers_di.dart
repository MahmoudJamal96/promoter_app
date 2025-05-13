import 'package:get_it/get_it.dart';

import '../data/repo/loggers_repo.dart';
import '../logic/loggers_cubit.dart';

class LoggersDI {
  final GetIt di;

  LoggersDI(this.di) {
    call();
  }

  void call() {
    di
        ..registerFactory(() => LoggersCubit(di()))
        ..registerFactory(() => LoggersRepo(di()));
  }
}
