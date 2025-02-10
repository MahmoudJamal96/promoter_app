import 'package:flutter/material.dart';

import 'profile/profile_screen.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserHeader(),
            Expanded(
              child: ListView(
                children: [
                  MenuItem(icon: Icons.dashboard, title: 'التقارير', onTap: () {}),
                  MenuItem(icon: Icons.email, title: 'الرسائل', onTap: () {}),
                  MenuItem(icon: Icons.request_page, title: 'طلب إجازة', onTap: () {}),
                  MenuItem(icon: Icons.task, title: 'مهامي', onTap: () {}),
                  MenuItem(icon: Icons.meeting_room, title: 'مقابلات', onTap: () {}),
                  MenuItem(icon: Icons.history, title: 'المقابلات السابقة', onTap: () {}),
                  MenuItem(icon: Icons.delivery_dining, title: 'طلبات التوصيل', onTap: () {}),
                  MenuItem(icon: Icons.info, title: 'عن الشركة', onTap: () {}),
                  MenuItem(icon: Icons.settings, title: 'الإعدادات', onTap: () {}),
                  MenuItem(icon: Icons.logout, title: 'تسجيل خروج', onTap: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
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
                Text('كريم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  MenuItem({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title, style: TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }
}
