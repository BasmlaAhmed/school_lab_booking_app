import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart' as p;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../util/app_color.dart';
import '../../viewmodel/device_provider.dart';
import '../../viewmodel/lab_provider.dart';
import 'student_profile_screen.dart';
import 'student_screen.dart';

class LabsListScreen extends StatefulWidget {
  const LabsListScreen({super.key});

  @override
  State<LabsListScreen> createState() => _LabsListScreenState();
}

class _LabsListScreenState extends State<LabsListScreen> {
  @override
  void initState() {
    super.initState();
    p.Provider.of<LabProvider>(context, listen: false).fetchLabs();
  }

  // String formatLabTime(String? dateTimeStr) {
  //   if (dateTimeStr == null || dateTimeStr.isEmpty) return "-";
  //   try {
  //     final dt = DateTime.parse(dateTimeStr);
  //     return "${dt.day}/${dt.month}/${dt.year} - ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  //   } catch (_) {
  //     return dateTimeStr;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final labProvider = p.Provider.of<LabProvider>(context);

    return Scaffold(
      backgroundColor:
          Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : AppColor.background,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor:
            Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : AppColor.background,
        elevation: 0,
        title: Text(
          "Labs",
          style: TextStyle(
            backgroundColor:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : AppColor.background,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // ===== REFRESH BUTTON =====
          IconButton(
            icon: Icon(Icons.refresh, size: 25.w, color: AppColor.primaryDark),
            onPressed: () async {
              final provider = p.Provider.of<LabProvider>(
                context,
                listen: false,
              );

              await provider.releaseExpired();
              await provider.fetchLabs();

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Refreshed")));
            },
          ),

          SizedBox(width: 8.w),

          // ===== PROFILE BUTTON =====
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => const StudentProfileScreen(
                          name: "Student Name",
                          email: "name@student.edu",
                          studentId: "20215501",
                          studentClass: "5A",
                          image: "",
                        ),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 22.r,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, size: 28.sp, color: Colors.grey[600]),
              ),
            ),
          ),
        ],
      ),
      body:
          labProvider.labs.isEmpty
              ? Center(
                child: CircularProgressIndicator(color: AppColor.primaryDark),
              )
              : ListView.builder(
                padding: EdgeInsets.all(15.w),
                itemCount: labProvider.labs.length,
                itemBuilder: (context, index) {
                  final lab = labProvider.labs[index];

                  final isAvailable = lab.status == "available";
                  final color =
                      isAvailable ? AppColor.available : AppColor.booked;

                  return Container(
                    margin: EdgeInsets.only(bottom: 15.h),
                    decoration: BoxDecoration(
                      color: AppColor.card,
                      borderRadius: BorderRadius.circular(15.r),
                      border: Border.all(color: AppColor.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(15.w),
                      leading: CircleAvatar(
                        radius: 28.r,
                        backgroundColor: color,
                        child: Icon(
                          Icons.computer,
                          color: AppColor.textPrimary,
                          size: 28.sp,
                        ),
                      ),
                      title: Text(
                        lab.name,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColor.textPrimary,
                        ),
                      ),
                      subtitle:
                          isAvailable
                              ? Text(
                                "Available",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: AppColor.primaryDark,
                                ),
                              )
                              : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Booked by: ENG / ${lab.bookedBy ?? "Unknown"}",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    "Class: ${lab.className ?? "-"}",
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      color: AppColor.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    "From: ${shortTime(lab.fromTime)}\nTo: ${shortTime(lab.toTime)}",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppColor.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: AppColor.primaryDark,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ChangeNotifierProvider(
                                  create:
                                      (_) => DeviceProvider(
                                        autoFetch: false,
                                      )..fetchDevices(labId: lab.id.toString()),
                                  child: StudentScreen(
                                    labId: lab.id.toString(),
                                  ),
                                ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }

  String shortTime(dynamic isoOrString) {
    if (isoOrString == null) return '-';
    try {
      final dt = DateTime.parse(isoOrString.toString()).toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year;
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$day/$month/$year - $hour:$minute $ampm';
    } catch (_) {
      return isoOrString.toString();
    }
  }
}
