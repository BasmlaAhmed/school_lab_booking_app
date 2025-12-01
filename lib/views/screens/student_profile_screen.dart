import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../util/app_color.dart';
import '../../util/logout_helper.dart';
import '../../viewmodel/theme_provider.dart';
import '../../viewmodel/user_provider.dart';

class StudentProfileScreen extends StatelessWidget {
  final String name;
  final String email;
  final String studentId;
  final String studentClass;
  final String image;

  const StudentProfileScreen({
    super.key,
    required this.name,
    required this.email,
    required this.studentId,
    required this.studentClass,
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
                      "Student Profile",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.sp,
                        color: isDark ? AppColor.background : Colors.black,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // صورة الطالب
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColor.primaryDark, width: 3.w),
                  ),
                  child: CircleAvatar(
                    radius: 60.r,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: image.isNotEmpty
                        ? AssetImage(image)
                        : null,
                    child: image.isEmpty
                        ? Icon(
                            Icons.person,
                            size: 60.sp,
                            color: Colors.grey[600],
                          )
                        : null,
                  ),
                ),
                SizedBox(height: 15.h),

                // الاسم
                Text(
                  userName,
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

                // الرول/مسار الطالب
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.primarylight,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    "Student",
                    style: TextStyle(
                      color: AppColor.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                ),

                SizedBox(height: 25.h),

                // معلومات الطالب في مربعات info tiles
                _infoTile("Student ID", studentId, isDark),
                _infoTile("Class", studentClass, isDark),

                SizedBox(height: 35.h),

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

  Widget _infoTile(String title, String value, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : AppColor.border,
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: AppColor.primaryDark, size: 22.sp),
          SizedBox(width: 10.w),
          Text(
            "$title:",
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColor.textsecondary : AppColor.textPrimary,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16.sp,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ),
        ],
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
