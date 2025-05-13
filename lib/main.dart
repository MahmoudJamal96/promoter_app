import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logger/logger.dart';
import 'package:promoter_app/core/di/injection_container.dart' as di;
import 'package:promoter_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:promoter_app/features/auth/screens/login_screen.dart';
import 'package:promoter_app/features/client/data/repositories/client_repository_impl.dart';
import 'package:promoter_app/features/client/domain/repositories/client_repository.dart';
import 'package:promoter_app/features/client/presentation/bloc/client_bloc.dart';
import 'package:promoter_app/features/client/cubit/client_cubit.dart';
import 'package:promoter_app/features/dashboard/dashboard_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_theme.dart';
import 'core/usecases/usecase.dart';

final logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize dependency injection
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      // Use builder only if you need to use library outside ScreenUtilInit context
      builder: (_, child) => MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => di.sl<AuthBloc>()..add(CheckAuthStatusEvent()),
          ),
          BlocProvider<ClientBloc>(
            create: (_) => di.sl<ClientBloc>()..add(LoadClientsEvent()),
          ),
          BlocProvider<ClientCubit>(
            create: (_) => ClientCubit(),
          ),
        ],
        child: SafeArea(
          child: MaterialApp(
            title: 'مندوب الياسين',
            theme: lightTheme(),
            debugShowCheckedModeBanner: false,
            // RTL Support
            locale:
                const Locale('ar', ''), // Set Arabic as the default language
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar', ''), // Arabic
              Locale('en', ''), // English
            ],
            // Force RTL direction for the entire app
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              );
            },
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthLoading || state is AuthInitial) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (state is AuthAuthenticated) {
                  return ZoomDrawerScreen();
                } else {
                  return const LoginScreen();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
