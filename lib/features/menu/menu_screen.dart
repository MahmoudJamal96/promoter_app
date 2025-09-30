import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:promoter_app/core/utils/sound_manager.dart';
import 'package:promoter_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:promoter_app/features/auth/screens/login_screen.dart';
import 'package:promoter_app/features/menu/previous_invoices.dart';
import 'package:promoter_app/features/menu/salary.dart';
import 'package:promoter_app/features/menu/setting_screen.dart';
import 'package:promoter_app/features/menu/tasks/Itinerary.dart';
import 'package:url_launcher/url_launcher.dart';

import 'delivery/delivery_screen.dart';
import 'leave_request/leave_request_screen_new.dart';
import 'messages/messages_screen.dart';
import 'profile/profile_screen.dart';
import 'reports/reports_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _selectedIndex = 0;
  void openWhatsapp(
      {required BuildContext context, required String? text, required String? number}) async {
    var whatsapp = number; //+92xx enter like this
    var whatsappURlAndroid = "whatsapp://send?phone=${whatsapp!}&text=$text";
    var whatsappURLIos = "https://wa.me/$whatsapp?text=${Uri.tryParse(text!)}";
    if (Platform.isIOS) {
      // for iOS phone only
      if (await canLaunchUrl(Uri.parse(whatsappURLIos))) {
        await launchUrl(Uri.parse(
          whatsappURLIos,
        ));
      } else {
        await launchUrl(Uri.parse(
          whatsappURLIos,
        ));
      }
    } else {
      // android , web
      if (await canLaunchUrl(Uri.parse(whatsappURlAndroid))) {
        await launchUrl(Uri.parse(whatsappURlAndroid));
      } else {
        await launchUrl(Uri.parse(whatsappURlAndroid));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF148ccd),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const UserHeader(),
            SizedBox(height: 20.h),
            Expanded(
              child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  children: [
                    MenuItem(
                      icon: Icons.person,
                      title: 'ملفي',
                      onTap: () {
                        SoundManager().playClickSound();
                        Navigator.push(
                            context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                      },
                      isSelected: _selectedIndex == 0,
                    ),
                    MenuItem(
                      icon: Icons.dashboard,
                      title: 'التقارير',
                      onTap: () {
                        _navigateTo(context, const ReportsScreen(), 1);
                      },
                      isSelected: _selectedIndex == 1,
                    ),
                    MenuItem(
                      icon: Icons.dashboard,
                      title: 'فواتيري السابقة',
                      onTap: () {
                        _navigateTo(context, const PreviousInvoicesScreen(), 2);
                      },
                      isSelected: _selectedIndex == 2,
                    ),
                    MenuItem(
                      icon: Icons.notifications,
                      title: 'الإشعارات',
                      onTap: () => _navigateTo(context, const MessagesScreen(), 3),
                      isSelected: _selectedIndex == 3,
                    ),
                    MenuItem(
                      icon: Icons.delivery_dining,
                      title: 'طلبات التوصيل',
                      onTap: () => _navigateTo(context, const DeliveryScreen(), 4),
                      isSelected: _selectedIndex == 4,
                    ),
                    MenuItem(
                      icon: Icons.route,
                      title: 'جدول خط السير',
                      onTap: () => _navigateTo(context, const ItineraryScreen(), 5),
                      isSelected: _selectedIndex == 5,
                    ),
                    MenuItem(
                      icon: Icons.account_balance_wallet,
                      title: 'بيان المرتب الشهري',
                      onTap: () => _navigateTo(context, const SalaryDetailsScreen(), 6),
                      isSelected: _selectedIndex == 6,
                    ),
                    MenuItem(
                      icon: Icons.request_page,
                      title: 'تقديم طلب اجازة',
                      onTap: () => _navigateTo(context, const LeaveRequestScreen(), 7),
                      isSelected: _selectedIndex == 7,
                    ),
                    // MenuItem(
                    //   icon: Icons.request_page,
                    //   title: 'الطباعة',
                    //   onTap: () => _navigateTo(context, const PrintingScreen(), 7),
                    //   isSelected: _selectedIndex == 7,
                    // ),
                    MenuItem(
                      icon: Icons.contact_support,
                      title: 'تواصل مع الإدارة',
                      onTap: () {
                        SoundManager().playClickSound();
                        openWhatsapp(
                            context: context,
                            text: "مرحبا, أتواصل معكم بخصوص",
                            number: "+201021721842");
                      },
                      isSelected: _selectedIndex == 8,
                    ),
                    MenuItem(
                      icon: Icons.settings,
                      title: 'إعدادات التطبيق',
                      onTap: () => {_navigateTo(context, const SettingScreen(), 9)},
                      isSelected: _selectedIndex == 9,
                    ),
                    SizedBox(height: 20.h),
                    MenuItem(
                      icon: Icons.logout,
                      title: 'تسجيل خروج',
                      onTap: () async {
                        SoundManager().playClickSound();
                        // Log the user out
                        // await AuthService.logout2();

                        // Navigate to login screen
                        // if (context.mounted) {
                        //   Navigator.of(context).pushAndRemoveUntil(
                        //     MaterialPageRoute(builder: (_) => const LoginScreen()),
                        //     (route) => false,
                        //   );
                        // }
                        // Show logout confirmation dialog
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: const Text('تسجيل الخروج'),
                                  content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          SoundManager().playClickSound();
                                          Navigator.pop(context);
                                        },
                                        child: const Text('إلغاء')),
                                    TextButton(
                                        onPressed: () {
                                          SoundManager().playClickSound();
                                          context.read<AuthBloc>().add(
                                                LogoutEvent(),
                                              );
                                          // Close dialog first
                                          Navigator.pop(context);
                                          Navigator.of(context).pushAndRemoveUntil(
                                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                                            (route) => false,
                                          );
                                        },
                                        child: const Text('تسجيل الخروج')),
                                  ],
                                ));
                      },
                      isSelected: false,
                      isLogout: true,
                    ),
                  ].animate(interval: 50.ms).fadeIn(duration: 300.ms)
                  // .slideX(begin: -0.1, end: 0),
                  ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'v1.0.0',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen, int index) {
    SoundManager().playClickSound();
    setState(() {
      _selectedIndex = index;
    });

    // Close the drawer
    ZoomDrawer.of(context)!.close();

    // Wait for drawer to close before navigating
    Future.delayed(const Duration(milliseconds: 300), () {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => screen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });
  }
}

class UserHeader extends StatelessWidget {
  const UserHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        SoundManager().playClickSound();
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
                radius: 30,
                backgroundColor: Colors.deepPurple,
                backgroundImage: context.watch<AuthBloc>().image == null
                    ? const AssetImage('assets/images/logo_banner.png')
                    : FileImage(File(context.watch<AuthBloc>().image!)) as ImageProvider),
            const SizedBox(width: 10),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                String userName = 'مستخدم';
                String userEmail = '@user';
                if (state is AuthAuthenticated) {
                  userName = state.user.name;
                  userEmail = '@${state.user.email.split('@')[0]}';
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(userEmail, style: const TextStyle(color: Colors.grey)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isLogout;

  const MenuItem(
      {super.key,
      required this.icon,
      this.isLogout = false,
      this.isSelected = false,
      required this.title,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(fontSize: 16, color: Colors.white)),
      onTap: onTap,
    );
  }
}
