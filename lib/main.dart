import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:promoter_app/features/auth/screens/login_screen.dart';
import 'package:promoter_app/features/auth/services/auth_service.dart';
import 'package:promoter_app/features/dashboard/dashboard_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
      builder: (_, child) => SafeArea(
        child: MaterialApp(
          title: 'مندوب الياسين',
          theme: lightTheme(),
          debugShowCheckedModeBanner: false,
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
          home: FutureBuilder<bool>(
            future: AuthService.isAuthenticated(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final isLoggedIn = snapshot.data ?? false;
              return isLoggedIn ? ZoomDrawerScreen() : const LoginScreen();
            },
          ),
        ),
      ),
    );
  }
}
