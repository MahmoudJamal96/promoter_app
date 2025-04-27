import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:promoter_app/features/dashboard/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      // Simulate login process
      await Future.delayed(const Duration(seconds: 2));

      // In a real app, you would verify credentials with your backend
      // For now, we'll just navigate to the dashboard

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Store authentication state
        // await AuthService.setLoggedIn(true, userName: _usernameController.text);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ZoomDrawerScreen(),
          ),
        );
      }
    }
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
                    'assets/images/yasin_app_logo.JPG',
                    width: 150.r,
                    height: 150.r,
                    color: Colors.blue, // Make the logo blue
                    colorBlendMode: BlendMode.srcIn, // Remove background
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
                      labelText: 'اسم المستخدم',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    textDirection: TextDirection.rtl,
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

                  SizedBox(height: 24.h),

                  // Login Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'تسجيل الدخول',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ).animate().fadeIn(
                      delay: 700.ms,
                      duration: 800
                          .ms), // Removed register option as users will be registered through the ERP system
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}
