// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:promoter_app/core/constants/assets.dart';
import 'package:promoter_app/core/utils/utils.dart';
import 'package:promoter_app/core/view/widgets/image_loader.dart';
import 'package:promoter_app/core/view/widgets/outlined_text.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 40.h),

            /// 🔹 Profile Header
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50.r,
                    backgroundColor: Colors.red.shade100,
                    child: Icon(
                      Icons.person_outline,
                      size: 60.r,
                      color: Colors.red.shade600,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    "Mr. Haitham",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    "رقم العضوية: 2025",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            /// 🔹 User Information Cards
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  OutlinedText(label: "رقم الهاتف", data: "+201129274823"),
                  SizedBox(height: 10.h),
                  OutlinedText(label: "المحافظة", data: "القاهرة"),
                  SizedBox(height: 10.h),
                  OutlinedText(label: "الحي", data: "الحي العاشر"),
                  SizedBox(height: 10.h),
                  OutlinedText(label: "اسم المخزن", data: "مخزن السعد"),
                  SizedBox(height: 10.h),
                  OutlinedText(label: "الموقع", data: "الموقع"),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            /// 🔹 Edit Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  minimumSize: Size(double.infinity, 50.h),
                ),
                child: Text(
                  "تعديل البيانات",
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }
}