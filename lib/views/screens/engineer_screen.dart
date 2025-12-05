import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart' as p;
import '../../model/lab_model.dart';
import '../../util/app_color.dart';
import '../../viewmodel/lab_provider.dart';
import 'engineer_profile_screen.dart';
import 'lab_info.dart';

class EngineerScreen extends StatelessWidget {
  const EngineerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final labProvider = p.Provider.of<LabProvider>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = p.Provider.of<LabProvider>(context, listen: false);
      await provider.releaseExpired();
      await provider.fetchLabs();
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,

        actions: [
          // ====== REFRESH BUTTON ======
          IconButton(
            icon: Icon(
              Icons.refresh,
              size: 30.sp,
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

          // ====== PROFILE BUTTON ======
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => EngineerProfileScreen(
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
                color: Theme.of(context).colorScheme.onBackground,
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
                color: isDark ? Colors.white : AppColor.textPrimary,
              ),
            ),
            SizedBox(height: 10.h),

            Text(
              "Check lab availability.",
              style: TextStyle(
                fontSize: 16.sp,
                color: (isDark ? Colors.white : AppColor.textPrimary)
                    .withOpacity(0.7),
              ),
            ),
            SizedBox(height: 35.h),

            Expanded(
              child: ListView(
                children:
                    labProvider.labs.map((lab) {
                      final isBooked = (lab.status ?? '') == "booked";
                      final bookedBy = lab.bookedBy ?? "Unknown";
                      final className = lab.className ?? "";
                      final fromTime = lab.fromTime ?? "";
                      final toTime = lab.toTime ?? "";

                      return InkWell(
                        onTap: () async {
                          if (isBooked) {
                            final formattedFrom = LabModel.formatTime(
                              lab.fromTime,
                            );
                            final formattedTo = LabModel.formatTime(lab.toTime);

                            showDialog(
                              context: context,
                              builder:
                                  (_) => AlertDialog(
                                    backgroundColor:
                                        Theme.of(context).dialogBackgroundColor,
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
                                      "From: $formattedFrom\n"
                                      "To: $formattedTo",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color:
                                            isDark
                                                ? Colors.white
                                                : AppColor.textPrimary,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          "OK",
                                          style: TextStyle(
                                            color: AppColor.primaryDark,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                            );
                            return;
                          }

                          await labProvider.fetchLabs();
                          final updatedLab = labProvider.labs.firstWhere(
                            (x) => x.id == lab.id,
                          );

                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => LabInfo(
                                    labId: updatedLab.id!,
                                    labName: updatedLab.name ?? "",
                                    labData: {
                                      "name": updatedLab.name ?? "",
                                      "status": updatedLab.status ?? "",
                                      "bookedBy": updatedLab.bookedBy ?? '',
                                      "className": updatedLab.className ?? '',
                                      "from": updatedLab.fromTime ?? '',
                                      "to": updatedLab.toTime ?? '',
                                    },
                                    engineerName:
                                        updatedLab.bookedBy ?? 'Engineer',
                                    lab: lab,
                                  ),
                            ),
                          );

                          if (result == true) {
                            labProvider.fetchLabs();
                          }
                        },

                        child: Container(
                          height: 60.h,
                          padding: EdgeInsets.symmetric(horizontal: 15.w),
                          margin: EdgeInsets.symmetric(vertical: 10.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: AppColor.primaryDark),
                            color: Theme.of(context).cardColor,
                            boxShadow: [
                              if (!isDark)
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
                                lab.name ?? 'Lab',
                                style: TextStyle(
                                  fontSize: 25.sp,
                                  color:
                                      isDark
                                          ? Colors.white
                                          : AppColor.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              Container(
                                width: 150.w,
                                height: 30.h,
                                decoration: BoxDecoration(
                                  color:
                                      isBooked
                                          ? AppColor.booked
                                          : AppColor.available,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    isBooked
                                        ? "Booked by $bookedBy"
                                        : "Available",
                                    style: TextStyle(
                                      color:
                                          isBooked
                                              ? Colors.white
                                              : (isDark
                                                  ? Colors.white
                                                  : AppColor.textPrimary),
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
