import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart' as p;
import '../../util/app_color.dart';
import '../../viewmodel/lab_provider.dart';
import 'engineer_profile_screen.dart';
import 'lab_info.dart';

class EngineerScreen extends StatelessWidget {
  const EngineerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final labProvider = p.Provider.of<LabProvider>(context);

    /// Load labs on screen opening (only if empty to avoid repeated calls)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
  final provider = p.Provider.of<LabProvider>(context, listen: false);

  await provider.releaseExpired();   // ← أهم خطوة!
  await provider.fetchLabs();        // ← بعدها هاتِ اللستة المحدثة
});


    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            size: 30.w,
            color: AppColor.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EngineerProfileScreen(
                      name: "Engineer Name",
                      email: "engineer@example.com",
                      role: "Engineer",
                      image: "",
                    ),
                  ),
                );
              },
              child: Icon(
                Icons.person,
                color: AppColor.primaryDark,
                size: 35.sp,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Engineer Dashboard",
              style: TextStyle(
                fontSize: 34.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.textPrimary,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              "Check lab availability.",
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColor.textPrimary.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 35.h),

            /// ---------- LAB LIST ----------
            Expanded(
              child: ListView(
                children: labProvider.labs.map((lab) {
                  final isBooked = (lab.status ?? '').toString() == "booked";
                  final bookedBy = lab.bookedBy?.toString() ?? "Unknown";
                  final className = lab.className?.toString() ?? "";
                  final fromTime = lab.fromTime?.toString() ?? "";
                  final toTime = lab.toTime?.toString() ?? "";

                  return InkWell(
                    onTap: () async {
                      if (isBooked) {
                        /// LAB IS BOOKED — SHOW ALERT ONLY
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            title: Text(
                              "Lab is Booked",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColor.primaryDark,
                              ),
                            ),
                            content: Text(
                              "Booked by: $bookedBy\n"
                              "Class: $className\n"
                              "From: $fromTime\n"
                              "To: $toTime",
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColor.textPrimary,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  "OK",
                                  style: TextStyle(color: AppColor.primaryDark),
                                ),
                              ),
                            ],
                          ),
                        );
                        return;
                      }

                      /// LAB AVAILABLE → OPEN DETAILS
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LabInfo(
                            labId: lab.id?.toString() ?? '',
                            labName: lab.name?.toString() ?? '',
                            labData: {
                              "name": lab.name?.toString() ?? '',
                              "status": lab.status?.toString() ?? '',
                              "bookedBy": lab.bookedBy?.toString() ?? '',
                              "className": lab.className?.toString() ?? '',
                              "from": lab.fromTime?.toString() ?? '',
                              "to": lab.toTime?.toString() ?? '',
                            },
                            engineerName:
                                lab.bookedBy?.toString() ?? 'Engineer',
                          ),
                        ),
                      );

                      if (result == true) {
                        labProvider.fetchLabs();
                      }
                    },

                    /// LAB CARD
                    child: Container(
                      height: 60.h,
                      padding: EdgeInsets.symmetric(horizontal: 15.w),
                      margin: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: AppColor.primaryDark),
                        color: AppColor.card,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            offset: const Offset(0, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            lab.name?.toString() ?? 'Lab',
                            style: TextStyle(
                              fontSize: 25.sp,
                              color: AppColor.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            width: 150.w,
                            height: 30.h,
                            decoration: BoxDecoration(
                              color: isBooked
                                  ? AppColor.booked
                                  : AppColor.available,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                isBooked ? "Booked by $bookedBy" : "Available",
                                style: TextStyle(
                                  color: isBooked
                                      ? Colors.white
                                      : AppColor.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}