import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../util/app_color.dart';

class StudentProfileScreen extends StatelessWidget {
  final String name;
  final String email;
  final String studentId;
  final String
      studentClass; // غيرت الاسم من Class لتجنب التعارض مع كلمة Dart المحجوزة
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
        elevation: 0,
        title: Text(
          "Student Profile",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // ---------- صورة الطالب -------------
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

            SizedBox(height: 20.h),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColor.primarylight,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                "Student",
                style: TextStyle(
                    color: AppColor.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp),
              ),
            ),

            SizedBox(height: 25.h),

            // ---------- معلومات الطالب -------------
            _infoTile("Student ID", studentId),
            _infoTile("Class", studentClass),
            _infoTile("Email", email),

            SizedBox(height: 35.h),

            // ---------- زر تسجيل الخروج -------------
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
  Widget _infoTile(String title, String value) {
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
