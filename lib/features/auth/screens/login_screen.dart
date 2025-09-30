import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:promoter_app/core/di/injection_container.dart';
import 'package:promoter_app/core/utils/sound_manager.dart';
import 'package:promoter_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:promoter_app/features/auth/data/models/token_model.dart';
import 'package:promoter_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:promoter_app/features/dashboard/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  SharedPreferences? _prefs;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();

  TokenModel? token;
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  bool rememmberMe = false;

  @override
  void initState() {
    super.initState();
    saveData();
    _initializeBiometric();
  }

  void saveData() {
    SharedPreferences.getInstance().then((prefs) {
      _prefs = prefs;
      final savedPhone = prefs.getString('login_phone');
      final savedPassword = prefs.getString('login_password');

      if (savedPhone != null && savedPassword != null) {
        _usernameController.text = savedPhone;
        _passwordController.text = savedPassword;
        rememmberMe = true;
      }
    });
  }

  Future<void> _initializeBiometric() async {
    try {
      token = await sl<AuthLocalDataSource>().getToken();
      SharedPreferences.getInstance().then((prefs) {
        _prefs = prefs;
        final firstLogin = prefs.getString('first_login_phone');
        if (firstLogin == null && token != null && token!.accessToken.isNotEmpty) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ZoomDrawerScreen(),
              ));
        }
      });
      // Check if biometric authentication is available
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();

      if (isAvailable && isDeviceSupported) {
        final List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();

        setState(() {
          _isBiometricAvailable = availableBiometrics.isNotEmpty;
          _isBiometricEnabled =
              token != null && token!.accessToken.isNotEmpty && _isBiometricAvailable;
        });
      }
    } catch (e) {
      debugPrint('Error initializing biometric: $e');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    SoundManager().playClickSound();
    SharedPreferences.getInstance().then((prefs) {
      _prefs = prefs;
      prefs.remove('first_login_phone');
    });
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            LoginEvent(
              email: _usernameController.text,
              password: _passwordController.text,
            ),
          );
    }
  }

  Future<void> _showBiometricPrompt() async {
    SoundManager().playClickSound();
    try {
      if (!_isBiometricAvailable) {
        _showErrorSnackBar('المصادقة البيومترية غير متوفرة على هذا الجهاز');
        return;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'يرجى استخدام بصمة الإصبع أو الوجه لتسجيل الدخول',
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'تسجيل الدخول بالبصمة',
            cancelButton: 'إلغاء',
            deviceCredentialsRequiredTitle: 'يرجى تأكيد هويتك',
            deviceCredentialsSetupDescription: 'يرجى إعداد قفل الشاشة أولاً',
            goToSettingsButton: 'الذهاب للإعدادات',
            goToSettingsDescription: 'يرجى إعداد المصادقة البيومترية في الإعدادات',
            biometricHint: 'ضع إصبعك على المستشعر',
            biometricNotRecognized: 'لم يتم التعرف على البصمة، حاول مرة أخرى',
            biometricRequiredTitle: 'المصادقة البيومترية مطلوبة',
            biometricSuccess: 'تم التعرف على البصمة بنجاح',
          ),
        ],
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          sensitiveTransaction: true,
        ),
      );

      if (didAuthenticate) {
        // If biometric authentication is successful, navigate to dashboard
        if (token != null && token!.accessToken.isNotEmpty) {
          // Verify token is still valid by triggering a silent auth check
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ZoomDrawerScreen(),
              ));
        } else {
          _showErrorSnackBar('جلسة تسجيل الدخول منتهية الصلاحية، يرجى تسجيل الدخول مرة أخرى');
        }
      }
    } catch (e) {
      debugPrint('Biometric authentication error: $e');
      _showErrorSnackBar('حدث خطأ في المصادقة البيومترية');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0.w),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo
                  Image.asset(
                    'assets/images/logo_banner.jpg',
                    width: 150.r,
                    height: 150.r,
                  ).animate().fadeIn(duration: 800.ms).scale(delay: 300.ms),

                  SizedBox(height: 20.h),

                  Text(
                    'قم بتسجيل الدخول للمتابعة',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[600],
                    ),
                  ).animate().fadeIn(delay: 400.ms, duration: 800.ms),

                  SizedBox(height: 40.h),

                  // Username Field
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'رقم الهاتف',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    textDirection: TextDirection.rtl,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال اسم المستخدم';
                      }
                      return null;
                    },
                  ).animate().fadeIn(delay: 500.ms, duration: 800.ms),

                  SizedBox(height: 16.h),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                    textDirection: TextDirection.rtl,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال كلمة المرور';
                      }
                      return null;
                    },
                  ).animate().fadeIn(delay: 600.ms, duration: 800.ms),

                  Row(
                    children: [
                      Checkbox(
                        value: rememmberMe,
                        onChanged: (value) {
                          setState(() {
                            rememmberMe = value ?? false;
                          });
                          if (rememmberMe) {
                            SharedPreferences.getInstance().then((prefs) {
                              prefs.setString('login_phone', _usernameController.text);
                              prefs.setString('login_password', _passwordController.text);
                            });
                          } else {
                            SharedPreferences.getInstance().then((prefs) {
                              prefs.remove('login_phone');
                              prefs.remove('login_password');
                            });
                          }
                        },
                      ),
                      Text(
                        'تذكرني',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ],
                  ).animate().fadeIn(delay: 600.ms, duration: 800.ms),
                  // Login Button
                  BlocConsumer<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is AuthError) {
                        _showErrorSnackBar(state.message);
                      } else if (state is AuthAuthenticated) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const ZoomDrawerScreen(),
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;

                      return ElevatedButton(
                        onPressed: isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'تسجيل ',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      );
                    },
                  ).animate().fadeIn(delay: 700.ms, duration: 800.ms),

                  // Biometric Login Button
                  if (_isBiometricEnabled)
                    Padding(
                      padding: EdgeInsets.only(top: 16.h),
                      child: InkWell(
                        onTap: _showBiometricPrompt,
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          padding: EdgeInsets.all(16.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF148ccd).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: const Color(0xFF148ccd).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.fingerprint,
                                color: const Color(0xFF148ccd),
                                size: 24.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'تسجيل الدخول بالبصمة',
                                style: TextStyle(
                                  color: const Color(0xFF148ccd),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 800.ms, duration: 800.ms),

                  // Biometric Setup Prompt (if biometric is available but not enabled)
                  if (_isBiometricAvailable && !_isBiometricEnabled && token == null)
                    Padding(
                      padding: EdgeInsets.only(top: 16.h),
                      child: Container(
                        padding: EdgeInsets.all(12.h),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: Colors.amber.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.amber[700],
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                'بعد تسجيل الدخول، يمكنك تفعيل المصادقة بالبصمة',
                                style: TextStyle(
                                  color: Colors.amber[700],
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 900.ms, duration: 800.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}
