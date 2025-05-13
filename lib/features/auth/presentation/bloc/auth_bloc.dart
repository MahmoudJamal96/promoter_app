import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:promoter_app/core/error/failures.dart';
import 'package:promoter_app/core/usecases/usecase.dart';
import 'package:promoter_app/features/auth/domain/entities/user.dart';
import 'package:promoter_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:promoter_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:promoter_app/features/auth/domain/usecases/logout_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase loginUsecase;
  final LogoutUsecase logoutUsecase;
  final GetCurrentUserUsecase getCurrentUserUsecase;

  AuthBloc({
    required this.loginUsecase,
    required this.logoutUsecase,
    required this.getCurrentUserUsecase,
  }) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final userResult = await getCurrentUserUsecase(NoParams());

    userResult.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final userResult = await loginUsecase(
      LoginParams(email: event.email, password: event.password),
    );

    userResult.fold(
      (failure) {
        if (failure is UnauthorizedFailure) {
          emit(const AuthError('Invalid credentials'));
        } else if (failure is ServerFailure) {
          emit(const AuthError('Server error'));
        } else if (failure is NoInternetFailure) {
          emit(const AuthError('No internet connection'));
        } else if (failure is ApiFailure) {
          emit(AuthError(failure.message));
        } else {
          emit(const AuthError('An error occurred'));
        }
      },
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await logoutUsecase(NoParams());

    result.fold(
      (failure) => emit(const AuthError('Failed to log out')),
      (_) => emit(AuthUnauthenticated()),
    );
  }
}
