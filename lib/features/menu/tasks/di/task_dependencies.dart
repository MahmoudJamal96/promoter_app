import 'package:get_it/get_it.dart';

import '../cubit/task_cubit.dart';
import '../repositories/task_repository.dart';

class TaskDependencies {
  static void register(GetIt sl) {
    // Register Task dependencies
    sl.registerFactory(() => TaskCubit(repository: sl<TaskRepository>()));
    sl.registerLazySingleton(() => TaskRepository(sl()));
  }
}
