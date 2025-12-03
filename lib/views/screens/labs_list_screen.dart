import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart' as p;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../util/app_color.dart';
import '../../viewmodel/device_provider.dart';
import '../../viewmodel/lab_provider.dart';
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
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
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
                                    "From: ${lab.fromTime ?? "-"}\nTo: ${lab.toTime ?? "-"}",

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
}
