import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart' as p;
import 'package:provider/provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final labProvider = p.Provider.of<LabProvider>(context);

    // theme shortcuts (safe defaults)
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final cardBg = theme.cardColor;
    // use colorScheme for reliable contrast
    final cs = theme.colorScheme;
    final textPrimary = cs.onSurface;
    final textSecondary = cs.onSurface.withOpacity(0.85);
    final subtleText = cs.onSurface.withOpacity(0.7);
    final primaryColor = Color.fromARGB(255, 85, 174, 88);
    final errorColor = cs.error;
    final iconPrimary =
        cs.onBackground; // icon color that contrasts with background
    final iconAccent = cs.onSurface;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        // ensure AppBar icons are visible
        iconTheme: IconThemeData(color: iconPrimary),
        title: Text(
          "Labs",
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        actions: [
          // ===== REFRESH BUTTON =====
          IconButton(
            icon: Icon(
              Icons.refresh,
              size: 25.w,
              color: Theme.of(context).colorScheme.onBackground,
            ),
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
                backgroundColor: theme.colorScheme.surfaceVariant,
                child: Icon(
                  Icons.person,
                  size: 28.sp,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),
          ),
        ],
      ),
      body:
          labProvider.labs.isEmpty
              ? Center(child: CircularProgressIndicator(color: primaryColor))
              : ListView.builder(
                padding: EdgeInsets.all(15.w),
                itemCount: labProvider.labs.length,
                itemBuilder: (context, index) {
                  final lab = labProvider.labs[index];
                  final isAvailable = lab.status == "available";

                  // circle colors (use colorScheme for consistency)
                  final circleBg =
                      isAvailable
                          ? primaryColor.withOpacity(0.18)
                          : errorColor.withOpacity(0.13);
                  final circleIconColor =
                      isAvailable
                          ? primaryColor
                          : Color.fromARGB(255, 245, 196, 92);

                  return Container(
                    margin: EdgeInsets.only(bottom: 15.h),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(15.r),
                      border: Border.all(color: AppColor.primaryDark),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black26 : Colors.black12,
                          blurRadius: isDark ? 2 : 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(15.w),
                      leading: CircleAvatar(
                        radius: 28.r,
                        backgroundColor: circleBg,
                        child: Icon(
                          Icons.computer,
                          color: circleIconColor,
                          size: 28.sp,
                        ),
                      ),
                      title: Text(
                        lab.name,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          height: 1.05,
                        ),
                      ),
                      subtitle:
                          isAvailable
                              ? Text(
                                "Available",
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                              : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4.h),
                                  Text(
                                    "Booked by: ENG / ${lab.bookedBy ?? "Unknown"}",
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      color: Color.fromARGB(255, 245, 196, 92),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    "Class: ${lab.className ?? "-"}",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: textSecondary,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    "From: ${shortTime(lab.fromTime)}\nTo: ${shortTime(lab.toTime)}",
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: subtleText,
                                    ),
                                  ),
                                ],
                              ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: iconAccent,
                        size: 18.sp,
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
