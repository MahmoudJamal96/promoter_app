import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

class MyBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    log(
      '🚀 [BLOC] Created: ${bloc.runtimeType} (instance: ${bloc.hashCode})',
      name: 'BlocObserver',
    );
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    log(
      '🎯 [BLOC] Event: ${bloc.runtimeType} ➔ ${event.runtimeType}',
      name: 'BlocObserver',
      error: event,
    );
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    log(
      '🔄 [BLOC] Change: ${bloc.runtimeType} (${bloc.hashCode})\n'
      'Current: ${change.currentState}\n'
      'Next: ${change.nextState}',
      name: 'BlocObserver',
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    log(
      '⛔ [BLOC] Error: ${bloc.runtimeType} (${bloc.hashCode})\n'
      'Error: $error\n'
      'Stack: ${stackTrace.toString().split('\n').take(5).join('\n')}',
      name: 'BlocObserver',
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    log(
      '🔒 [BLOC] Closed: ${bloc.runtimeType} (${bloc.hashCode})',
      name: 'BlocObserver',
    );
  }
}
