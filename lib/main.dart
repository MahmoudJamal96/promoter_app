import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:promoter_app/core/di/bloc_observer.dart';
import 'package:promoter_app/core/di/injection_container.dart' as di;
import 'package:promoter_app/core/utils/sound_manager.dart';
import 'package:promoter_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:promoter_app/features/auth/screens/login_screen.dart';
import 'package:promoter_app/features/salary/cubit/salary_cubit.dart';

import 'app_theme.dart';
import 'features/client/cubit/client_cubit_service.dart';
import 'features/menu/tasks/di/setup_tasks.dart';

final logger = Logger();
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // Initialize Google Maps for Android
  if (Platform.isAndroid) {
    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  }
  Bloc.observer = MyBlocObserver();
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]); // Initialize dependency injection
  await di.init();
  SoundManager().initialize();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFF148ccd), // Set the status bar color
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF148ccd), // Set the navigation bar color
  ));
  // Register feature dependencies
  setupTasksDependencies();

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
          // Use API connected ClientCubit
          BlocProvider(
            create: (_) => di.sl<ClientCubit>(),
          ),
          // Add SalaryCubit
          BlocProvider(
            create: (_) => di.sl<SalaryCubit>(),
          ),
        ],
        child: SafeArea(
          child: MaterialApp(
            title: 'مندوب الياسين',
            theme: lightTheme(),

            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            // RTL Support
            locale: const Locale('ar', ''), // Set Arabic as the default language
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
            home: const LocationPermissionWrapper(),
          ),
        ),
      ),
    );
  }
}

class LocationPermissionWrapper extends StatefulWidget {
  const LocationPermissionWrapper({super.key});

  @override
  State<LocationPermissionWrapper> createState() => _LocationPermissionWrapperState();
}

class _LocationPermissionWrapperState extends State<LocationPermissionWrapper> {
  bool _isCheckingPermission = true;
  bool _hasLocationPermission = false;
  bool _showPermissionDeniedDialog = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    setState(() {
      _isCheckingPermission = true;
    });

    // Check current permission status
    PermissionStatus status = await Permission.location.status;

    if (status.isGranted) {
      setState(() {
        _hasLocationPermission = true;
        _isCheckingPermission = false;
      });
    } else if (status.isDenied) {
      // Request permission
      _requestLocationPermission();
    } else if (status.isPermanentlyDenied) {
      setState(() {
        _showPermissionDeniedDialog = true;
        _isCheckingPermission = false;
      });
    }
  }

  Future<void> _requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();

    if (status.isGranted) {
      setState(() {
        _hasLocationPermission = true;
        _isCheckingPermission = false;
      });
    } else if (status.isPermanentlyDenied) {
      setState(() {
        _showPermissionDeniedDialog = true;
        _isCheckingPermission = false;
      });
    } else {
      // Permission denied but not permanently
      setState(() {
        _isCheckingPermission = false;
      });
    }
  }

  void _openAppSettings() {
    openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingPermission) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'جاري التحقق من أذونات الموقع...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (_showPermissionDeniedDialog) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_off,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),
                const Text(
                  'مطلوب إذن الموقع',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'هذا التطبيق يحتاج إلى إذن الوصول للموقع للعمل بشكل صحيح. يرجى تفعيل إذن الموقع من الإعدادات.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _openAppSettings,
                  child: const Text('فتح الإعدادات'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _checkLocationPermission,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_hasLocationPermission) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_on,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),
                const Text(
                  'مطلوب إذن الموقع',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'هذا التطبيق يحتاج إلى إذن الوصول للموقع للعمل بشكل صحيح.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _requestLocationPermission,
                  child: const Text('السماح بالوصول للموقع'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // If permission is granted, show the main app
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is AuthAuthenticated) {
          return const LoginScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
