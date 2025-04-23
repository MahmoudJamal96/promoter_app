import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60.r,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: AssetImage('assets/profile_placeholder.png'),
                      ).animate().fade(duration: 600.ms),
                      Positioned(
                        bottom: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            "Uploading image...",
                            style: TextStyle(color: Colors.white, fontSize: 12.sp),
                          ),
                        ).animate().slide(
                            begin: const Offset(0, -40),
                            end: Offset.zero,
                            duration: 800.ms,
                            curve: Curves.easeOut),
                      )
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    "Jessy Prachette",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    "@jessy_p",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            /// 🔹 User Information Form Fields
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  _buildTextField(label: "Mobile", initialValue: "+2347011188896"),
                  _buildTextField(
                      label: "Bio",
                      initialValue:
                          "I am an avid learner here on FavYogis, UI/UX designer, brand and event designer."),
                  _buildTextField(label: "Behance link", initialValue: "https://behance.com/jessy_p"),
                  _buildTextField(label: "Dribbble link", initialValue: ""),
                ].animate(interval: 100.ms).fade(duration: 500.ms),
              ),
            ),

            SizedBox(height: 20.h),

            /// 🔹 Save Button with Animation
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
                  "Save Profile",
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
              )
                  .animate()
                  .fade(duration: 400.ms)
                  .scale(delay: 300.ms, duration: 500.ms)
                  .shake(curve: Curves.elasticOut),
            ),

            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, String? initialValue}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          initialValue: initialValue,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }
}
