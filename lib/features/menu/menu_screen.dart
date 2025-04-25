import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:lottie/lottie.dart';

import 'profile/profile_screen.dart';
import 'reports/reports_screen.dart';
import 'messages/messages_screen.dart';
import 'leave_request/leave_request_screen.dart';
import 'tasks/tasks_screen.dart';
import 'meetings/meetings_screen.dart';
import 'delivery/delivery_screen.dart';

class MenuScreen extends StatefulWidget {
  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.9),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserHeader(),
            SizedBox(height: 20.h),
            Expanded(
              child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  children: [
                    MenuItem(
                      icon: Icons.dashboard,
                      title: 'التقارير',
                      onTap: () => _navigateTo(context, ReportsScreen(), 0),
                      isSelected: _selectedIndex == 0,
                    ),
                    MenuItem(
                      icon: Icons.email,
                      title: 'الرسائل',
                      onTap: () => _navigateTo(context, MessagesScreen(), 1),
                      isSelected: _selectedIndex == 1,
                    ),
                    MenuItem(
                      icon: Icons.request_page,
                      title: 'طلب إجازة',
                      onTap: () =>
                          _navigateTo(context, LeaveRequestScreen(), 2),
                      isSelected: _selectedIndex == 2,
                    ),
                    MenuItem(
                      icon: Icons.task,
                      title: 'مهامي',
                      onTap: () => _navigateTo(context, TasksScreen(), 3),
                      isSelected: _selectedIndex == 3,
                    ),
                    MenuItem(
                      icon: Icons.meeting_room,
                      title: 'مقابلات',
                      onTap: () => _navigateTo(context, MeetingsScreen(), 4),
                      isSelected: _selectedIndex == 4,
                    ),
                    MenuItem(
                      icon: Icons.history,
                      title: 'المقابلات السابقة',
                      onTap: () => _navigateTo(
                          context, MeetingsScreen(pastMeetings: true), 5),
                      isSelected: _selectedIndex == 5,
                    ),
                    MenuItem(
                      icon: Icons.delivery_dining,
                      title: 'طلبات التوصيل',
                      onTap: () => _navigateTo(context, DeliveryScreen(), 6),
                      isSelected: _selectedIndex == 6,
                    ),
                    MenuItem(
                      icon: Icons.info,
                      title: 'عن الشركة',
                      onTap: () => {
                        // _navigateTo(context, AboutScreen(), 7)
                      },
                      isSelected: _selectedIndex == 7,
                    ),
                    MenuItem(
                      icon: Icons.settings,
                      title: 'الإعدادات',
                      onTap: () => {
                        // _navigateTo(context, SettingsScreen(), 8)
                      },
                      isSelected: _selectedIndex == 8,
                    ),
                    SizedBox(height: 20.h),
                    MenuItem(
                      icon: Icons.logout,
                      title: 'تسجيل خروج',
                      onTap: () {
                        // Show logout confirmation dialog
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Text('تسجيل الخروج'),
                                  content:
                                      Text('هل أنت متأكد من تسجيل الخروج؟'),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('إلغاء')),
                                    TextButton(
                                        onPressed: () {
                                          // Close dialog first
                                          Navigator.pop(context);

                                          // Implement logout functionality
                                          // _handleLogout(context);
                                        },
                                        child: Text('تسجيل الخروج')),
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
            Padding(
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
    setState(() {
      _selectedIndex = index;
    });

    // Close the drawer
    ZoomDrawer.of(context)!.close();

    // Wait for drawer to close before navigating
    Future.delayed(Duration(milliseconds: 300), () {
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
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => ProfileScreen()));
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.person, color: Colors.white, size: 30),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('كريم',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('@a', style: TextStyle(color: Colors.grey)),
              ],
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

  MenuItem(
      {required this.icon,
      this.isLogout = false,
      this.isSelected = false,
      required this.title,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title, style: TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }
}
