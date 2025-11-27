import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../util/app_color.dart';

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
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        backgroundColor: AppColor.primaryDark,
        title: Text(
          "Engineer Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // صورة البروفايل
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColor.primaryDark, width: 3.w),
              ),
              child: CircleAvatar(
                radius: 60.r,
                backgroundColor: Colors.grey[300],
                backgroundImage: image.isNotEmpty ? AssetImage(image) : null,
                child: image.isEmpty
                    ? Icon(Icons.person, size: 60.sp, color: Colors.grey[600])
                    : null,
              ),
            ),

            SizedBox(height: 15.h),

            Text(
              name,
              style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textPrimary),
            ),

            SizedBox(height: 5.h),

            Text(
              email,
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
            ),

            SizedBox(height: 15.h),

            Container(
              padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 14.w),
              decoration: BoxDecoration(
                color: AppColor.primarylight,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                role,
                style: TextStyle(
                    color: AppColor.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp),
              ),
            ),

            SizedBox(height: 25.h),

            // معلومات البروفايل
            _buildInfoCard("Name", name),
            _buildInfoCard("Email", email),
            _buildInfoCard("Role", role),

            SizedBox(height: 35.h),

            // زر تسجيل الخروج
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                height: 55.h,
                decoration: BoxDecoration(
                  color: AppColor.primaryDark,
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Center(
                  child: Text(
                    "Log Out",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // عنصر بيانات واحد
  Widget _buildInfoCard(String title, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: AppColor.border, width: 1.w),
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
                color: AppColor.textPrimary),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[700],
              ),
            ),
          )
        ],
      ),
    );
  }
}
