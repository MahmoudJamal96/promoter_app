import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promoter_app/core/error/failures.dart';
import 'package:promoter_app/core/usecases/usecase.dart';
import 'package:promoter_app/features/auth/domain/entities/user.dart';
import 'package:promoter_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:promoter_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:promoter_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    getImage();
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

  String? image;
  Future<void> getImage() async {
    final prefs = await SharedPreferences.getInstance();
    image = prefs.getString('profile_image');
    emit(AuthImageLoaded(image));
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
        switch (failure.runtimeType) {
          case UnauthorizedFailure:
            emit(const AuthError('Invalid credentials'));
            break;
          case ServerFailure:
            emit(const AuthError('Server error'));
            break;
          case NoInternetFailure:
            emit(const AuthError('No internet connection'));
            break;
          case ApiFailure:
            emit(AuthError((failure as ApiFailure).message));
            break;
          default:
            emit(const AuthError('An unknown error occurred'));
        }
      },
      (user) {
        emit(AuthAuthenticated(user));
      },
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
