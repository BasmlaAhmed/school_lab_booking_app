import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../util/app_color.dart';
import '../../viewmodel/device_provider.dart';
import 'student_profile_screen.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  Map<String, Timer> timers = {};

  void _showBookingDialog(
    BuildContext context,
    String deviceName,
    Map<String, dynamic> deviceData,
  ) {
    final TextEditingController studentName = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedFrom;
    TimeOfDay? selectedTo;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (ctx, setStateDialog) => AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  title: Text(
                    "Book $deviceName",
                    style: TextStyle(
                      color: AppColor.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: SizedBox(
                    height: 200.h,
                    child: Column(
                      children: [
                        TextField(
                          controller: studentName,
                          decoration: InputDecoration(
                            labelText: "Student Name",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        ElevatedButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null)
                              setStateDialog(() => selectedDate = picked);
                          },
                          child: Text(
                            selectedDate == null
                                ? "Select Date"
                                : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                            style: TextStyle(color: AppColor.textPrimary),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        ElevatedButton(
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (picked != null)
                              setStateDialog(() => selectedFrom = picked);
                          },
                          child: Text(
                            selectedFrom == null
                                ? "Select Start Time"
                                : "From: ${selectedFrom!.format(context)}",
                            style: TextStyle(color: AppColor.textPrimary),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        ElevatedButton(
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (picked != null)
                              setStateDialog(() => selectedTo = picked);
                          },
                          child: Text(
                            selectedTo == null
                                ? "Select End Time"
                                : "To: ${selectedTo!.format(context)}",
                            style: TextStyle(color: AppColor.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primaryDark,
                      ),
                      onPressed: () {
                        if (studentName.text.isEmpty ||
                            selectedFrom == null ||
                            selectedTo == null ||
                            selectedDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Please complete all fields"),
                            ),
                          );
                          return;
                        }

                        Provider.of<DeviceProvider>(
                          context,
                          listen: false,
                        ).bookDevice(deviceName, {
                          "student": studentName.text,
                          "date":
                              "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                          "from": selectedFrom!.format(context),
                          "to": selectedTo!.format(context),
                        });

                        Navigator.pop(context);
                      },
                      child: Text(
                        "Confirm",
                        style: TextStyle(color: AppColor.textsecondary),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  Widget _deviceBox(BuildContext context, Map<String, dynamic> device) {
    String status = device["status"];
    Color bg = Colors.white;
    Color border = Colors.grey.shade300;
    Color txt = AppColor.textPrimary;

    if (status == "booked") {
      bg = AppColor.booked.withOpacity(0.3);
      border = AppColor.booked;
    } else if (status == "not_working") {
      bg = AppColor.repair.withOpacity(0.3);
      border = AppColor.repair;
    }

    return Expanded(
      child: InkWell(
        onTap:
            status == "available"
                ? () => _showBookingDialog(context, device["name"], device)
                : null,
        child: Container(
          padding: EdgeInsets.all(12.r),
          margin: EdgeInsets.symmetric(horizontal: 5.w),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                device["name"],
                style: TextStyle(
                  color: txt,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                status == "available"
                    ? "Available"
                    : status == "booked"
                    ? "Booked"
                    : "Not Working",
                style: TextStyle(
                  color: txt,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (status == "booked")
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 3.h),
                    Text(
                      "By: ${device["student"]}",
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColor.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "Date: ${device["date"]}",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColor.textPrimary.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      "From ${device["from"]} - To ${device["to"]}",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColor.textPrimary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              if (status == "not_working")
                Text(
                  device["reason"],
                  style: TextStyle(color: AppColor.repair, fontSize: 11.sp),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pairContainer(BuildContext context, List<Map<String, dynamic>> pair) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [_deviceBox(context, pair[0]), _deviceBox(context, pair[1])],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceProvider = Provider.of<DeviceProvider>(context);

    // افصل الأجهزة على شكل أزواج
    List<List<Map<String, dynamic>>> devicePairs = [];
    List<Map<String, dynamic>> temp = [];
    deviceProvider.devices.forEach((key, value) {
      temp.add({"name": key, ...value});
      if (temp.length == 2) {
        devicePairs.add(List.from(temp));
        temp.clear();
      }
    });
    if (temp.isNotEmpty) devicePairs.add(List.from(temp));

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: AppColor.textPrimary),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => StudentProfileScreen(
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
      body: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "PC Booking",
              style: TextStyle(
                fontSize: 32.sp,
                color: AppColor.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: ListView.builder(
                itemCount: devicePairs.length,
                itemBuilder:
                    (context, index) =>
                        _pairContainer(context, devicePairs[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
