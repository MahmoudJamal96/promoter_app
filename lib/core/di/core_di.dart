/*
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:promoter_app/core/logic/version_cubit/version_cubit.dart';

import '../data/api_manager.dart';
import '../logic/preferences_cubit/preferences_cubit.dart';
//
// class CoreDI {
//   CoreDI(this.di, {PreferencesCubit? preferencesCubit}) {
//     call(preferencesCubit: preferencesCubit);
//   }
//
//   final GetIt di;
//
//   void call({PreferencesCubit? preferencesCubit}) {
//     final List<Interceptor> interceptors = [];
//     // if (AppLogger.instance.aliceInterceptor != null) {
//     //   interceptors.add(AppLogger.instance.aliceInterceptor!);
//     // }
//     di
//       ..registerLazySingleton(
//         () => APIsManager(
//           interceptors: interceptors,
//         ),
//       )
//       ..registerLazySingleton(() => preferencesCubit ?? PreferencesCubit());
//     di.registerLazySingleton<BasicCubit>(
//           () => BasicCubit(
//       ),
//     );
//     // ..registerLazySingleton(() => DeeplinkCubit());
//   }
// }
class CoreDI {
  CoreDI(this.di, {PreferencesCubit? preferencesCubit}) {
    call(preferencesCubit: preferencesCubit);
  }

  final GetIt di;

  void call({PreferencesCubit? preferencesCubit}) {
    if(!di.isRegistered<APIsManager>()) {
      di.registerLazySingleton(() => APIsManager());
    }
    if(!di.isRegistered<PreferencesCubit>()) {
      di.registerLazySingleton<PreferencesCubit>(() =>PreferencesCubit());
    }
    if(!di.isRegistered<VersionCubit>()) {
      di.registerLazySingleton<VersionCubit>(() =>VersionCubit());
    }

  }
}*/
