import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../util/app_color.dart';
import '../../util/logout_helper.dart';
import '../../viewmodel/theme_provider.dart';
import '../../viewmodel/user_provider.dart';

class EngineerProfileScreen extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final String image;

  const EngineerProfileScreen({
    super.key,
    required this.name,
    required this.email,
    required this.role,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.userName ?? "No Name";
    final userEmail = userProvider.userEmail ?? "No Email";
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark =
        themeProvider.themeMode == ThemeMode.dark ||
        (themeProvider.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppColor.background,
      body: SafeArea(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          color: isDark ? Colors.black : AppColor.background,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // السطر العلوي: سهم رجوع + العنوان
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: isDark ? AppColor.background : Colors.black,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      "Engineer Profile",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.sp,
                        color: isDark ? AppColor.background : Colors.black,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // الصورة
                CircleAvatar(
                  radius: 60.r,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: image.isNotEmpty ? AssetImage(image) : null,
                  child: image.isEmpty
                      ? Icon(Icons.person, size: 60.sp, color: Colors.grey[600])
                      : null,
                ),
                SizedBox(height: 15.h),

                // الاسم
                Text(
                 "ENG / ${userName}",
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColor.textPrimary,
                  ),
                ),

                SizedBox(height: 5.h),

                // الإيميل
                Text(
                  userEmail,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),

                SizedBox(height: 15.h),

                // الرول
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 8.h,
                    horizontal: 20.w,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.primarylight,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    role,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: AppColor.textPrimary,
                    ),
                  ),
                ),

                SizedBox(height: 40.h),

                // المربعين: Theme و Log Out
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _showThemeBottomSheet(context),
                        borderRadius: BorderRadius.circular(20.r),
                        child: Container(
                          padding: EdgeInsets.all(16.w),
                          margin: EdgeInsets.only(right: 10.w),
                          decoration: BoxDecoration(
                            color: AppColor.primarylight,
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                offset: const Offset(0, 4),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.palette,
                                size: 28.sp,
                                color: AppColor.primaryDark,
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                "Theme",
                                style: TextStyle(
                                  color: AppColor.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => showLogoutDialog(context, isDark: isDark),
                        borderRadius: BorderRadius.circular(20.r),
                        child: Container(
                          padding: EdgeInsets.all(16.w),
                          margin: EdgeInsets.only(left: 10.w),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color.fromARGB(255, 0, 0, 0)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: AppColor.primaryDark),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                offset: const Offset(0, 4),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.logout,
                                size: 28.sp,
                                color: AppColor.primaryDark,
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                "Log Out",
                                style: TextStyle(
                                  color: AppColor.primaryDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showThemeBottomSheet(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      builder: (_) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Select Theme",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.textPrimary,
              ),
            ),
            SizedBox(height: 15.h),
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text("Light"),
              onTap: () {
                themeProvider.setTheme(AppTheme.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text("Dark"),
              onTap: () {
                themeProvider.setTheme(AppTheme.dark);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone_android),
              title: const Text("System Default"),
              onTap: () {
                themeProvider.setTheme(AppTheme.system);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
