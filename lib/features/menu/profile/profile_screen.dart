import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:promoter_app/features/auth/presentation/bloc/auth_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Profile',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined,
                color: theme.colorScheme.onSurface),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 15.h),

            /// 🔹 Profile Header with Stats
            _buildProfileHeader(context),

            SizedBox(height: 20.h),

            /// 🔹 Profile Stats
            _buildProfileStats(context),

            SizedBox(height: 20.h),

            /// 🔹 User Information Form Fields
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 8.w, bottom: 10.h),
                    child: Text(
                      "Personal Information",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
                    String userName = "User";
                    String userEmail = "user@example.com";
                    String userPhone = "+000000000";

                    if (state is AuthAuthenticated) {
                      userName = state.user.name;
                      userEmail = state.user.email;
                      userPhone = state.user.phone ?? "+000000000";
                    }

                    return Column(
                      children: [
                        _buildTextField(
                            label: "Full Name", initialValue: userName),
                        _buildTextField(
                            label: "Email", initialValue: userEmail),
                        _buildTextField(
                            label: "Mobile", initialValue: userPhone),
                        _buildTextField(
                          label: "Bio",
                          initialValue: "مندوب مبيعات",
                          maxLines: 3,
                        ),
                      ],
                    );
                  }),
                  SizedBox(height: 20.h),
                  Padding(
                    padding: EdgeInsets.only(left: 8.w, bottom: 10.h),
                    child: Text(
                      "Social Links",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  _buildSocialLinkField(
                      label: "Behance",
                      icon: Icons.link,
                      initialValue: "https://behance.com/jessy_p"),
                  _buildSocialLinkField(
                      label: "Dribbble", icon: Icons.link, initialValue: ""),
                ],
              ).animate().fade(duration: 500.ms),
            ),

            SizedBox(height: 20.h),

            /// 🔹 Additional Settings Section
            _buildAdditionalSettings(context),

            SizedBox(height: 20.h),

            /// 🔹 Save Button with Animation
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  minimumSize: Size(double.infinity, 50.h),
                  elevation: 2,
                ),
                child: Text(
                  "Save Profile",
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
              )
                  .animate()
                  .fade(duration: 400.ms)
                  .scale(delay: 300.ms, duration: 500.ms)
                  .shimmer(delay: 700.ms, duration: 1000.ms),
            ),

            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 50.r,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage:
                      const AssetImage('assets/profile_placeholder.png'),
                )
                    .animate()
                    .fade(duration: 600.ms)
                    .scale(begin: 0.8, end: 1, duration: 500.ms),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.black,
                    size: 16.sp,
                  ),
                ).animate().fade(delay: 300.ms, duration: 300.ms),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              String userName = "User";
              if (state is AuthAuthenticated) {
                userName = state.user.name;
              }
              return Text(
                userName,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ).animate().fade(duration: 400.ms);
            },
          ),
          SizedBox(height: 5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified,
                size: 16.sp,
                color: theme.colorScheme.secondary,
              ),
              SizedBox(width: 5.w),
              Text(
                "Verified Promoter",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ).animate().fade(delay: 200.ms, duration: 400.ms),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildProfileBadge(context, "Premium", Icons.star),
              SizedBox(width: 10.w),
              _buildProfileBadge(context, "Top Performer", Icons.emoji_events),
            ],
          ).animate().fade(delay: 300.ms, duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildProfileBadge(BuildContext context, String label, IconData icon) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: theme.colorScheme.secondary,
            size: 14.sp,
          ),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStats(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(context, "35", "Promotions"),
          _buildDivider(),
          _buildStatItem(context, "12", "Events"),
          _buildDivider(),
          _buildStatItem(context, "98%", "Success Rate"),
        ],
      ).animate().fade(duration: 500.ms),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40.h,
      width: 1,
      color: Colors.grey.withOpacity(0.2),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalSettings(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
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
          _buildSettingItem(
            context,
            "Notifications",
            Icons.notifications_outlined,
            showToggle: true,
            initialValue: true,
          ),
          _buildSettingItem(
            context,
            "Privacy Settings",
            Icons.privacy_tip_outlined,
            showChevron: true,
          ),
          _buildSettingItem(
            context,
            "Account Security",
            Icons.security_outlined,
            showChevron: true,
          ),
          _buildSettingItem(
            context,
            "Help & Support",
            Icons.help_outline,
            showChevron: true,
            showDivider: false,
          ),
        ],
      ).animate().fade(duration: 500.ms),
    );
  }

  Widget _buildSettingItem(BuildContext context, String title, IconData icon,
      {bool showToggle = false,
      bool showChevron = false,
      bool initialValue = false,
      bool showDivider = true}) {
    final theme = Theme.of(context);

    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20.sp,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: showToggle
              ? Switch(
                  value: initialValue,
                  activeColor: theme.colorScheme.primary,
                  onChanged: (value) {},
                )
              : showChevron
                  ? Icon(
                      Icons.chevron_right,
                      color: Colors.grey.shade600,
                    )
                  : null,
          onTap: () {},
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 70.w,
            endIndent: 20.w,
          ),
      ],
    );
  }

  Widget _buildTextField(
      {required String label, String? initialValue, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          initialValue: initialValue,
          maxLines: maxLines,
          decoration: InputDecoration(
            contentPadding:
                EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.blue.shade500),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildSocialLinkField(
      {required String label, required IconData icon, String? initialValue}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          initialValue: initialValue,
          decoration: InputDecoration(
            contentPadding:
                EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.blue.shade500),
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(icon, color: Colors.blue.shade400),
            hintText: "Enter URL",
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}
