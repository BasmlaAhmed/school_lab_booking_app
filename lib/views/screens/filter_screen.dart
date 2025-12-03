import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../util/app_color.dart';
import '../../viewmodel/device_provider.dart';
import 'engineer_screen.dart';
import 'labs_list_screen.dart';
import 'student_screen.dart';

class FilterScreen extends StatelessWidget {
  const FilterScreen({super.key});

  void _showCodeDialog(BuildContext context, VoidCallback onSuccess) {
    final TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColor.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            "Enter Access Code",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
              color: AppColor.textPrimary,
            ),
          ),
          content: TextField(
            controller: codeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "Type your code",
              hintStyle: TextStyle(
                color: AppColor.textPrimary.withOpacity(0.4),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 15.w,
                vertical: 12.h,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: AppColor.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(
                  color: AppColor.primaryDark,
                  width: 1.5,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16.sp,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onPressed: () {
                String code = codeController.text.trim();
                if (code.isNotEmpty) {
                  Navigator.pop(context);
                  onSuccess();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Please enter a valid code"),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              child: Text(
                "Confirm",
                style: TextStyle(
                  color: AppColor.textsecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceProvider = Provider.of<DeviceProvider>(context);

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Select Role",
          style: TextStyle(
            color: AppColor.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22.sp,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Choose your role",
              style: TextStyle(
                fontSize: 36.sp,
                fontWeight: FontWeight.bold,
                height: 1.1,
                color: AppColor.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Tell us who you are to personalize your experience.",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16.sp,
                color: AppColor.textPrimary.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 35.h),
            RoleCard(
              title: "Engineer",
              icon: Icons.engineering,
              bgColor: AppColor.primaryDark,
              textColor: AppColor.textsecondary,
              onTap: () {
                _showCodeDialog(context, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EngineerScreen(),
                    ),
                  );
                });
              },
            ),
            SizedBox(height: 20.h),
            RoleCard(
              title: "Student",
              icon: Icons.school,
              bgColor: AppColor.primarylight,
              textColor: AppColor.textPrimary,
              onTap: () {
                _showCodeDialog(context, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LabsListScreen(),
                    ),
                  );
                });
              },
            ),
            
          ],
        ),
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color bgColor;
  final Color textColor;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.title,
    required this.icon,
    required this.bgColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22.r),
      splashColor: Colors.black12,
      child: Container(
        height: 95.h,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(22.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.09),
              offset: const Offset(0, 3),
              blurRadius: 6,
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 30.sp),
            SizedBox(width: 12.w),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 26.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
