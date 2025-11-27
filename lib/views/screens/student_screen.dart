// views/screens/student_screen.dart
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

  @override
  void initState() {
    super.initState();
    // Load latest devices when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DeviceProvider>(context, listen: false).fetchDevices();
    });
  }

  void _showBookingDialog(
    BuildContext context,
    String deviceName,
    Map<String, dynamic> deviceData,
  ) {
    final TextEditingController notesController = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedFrom;
    TimeOfDay? selectedTo;

    // حماية إضافية: لو الجهاز مش متاح مانعرضش الحوار للحجز
    final status = (deviceData['status'] ?? 'available').toString();
    if (status != 'available') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'not_working'
                ? 'This device is reported as not working — cannot book.'
                : 'This device is not available for booking.',
          ),
        ),
      );
      return;
    }

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
                    height: 135.h,
                    child: Column(
                      children: [
                        // TextField(
                        //   controller: notesController,
                        //   decoration: InputDecoration(
                        //     labelText: "Notes (optional)",
                        //     border: OutlineInputBorder(
                        //       borderRadius: BorderRadius.circular(12.r),
                        //     ),
                        //   ),
                        // ),
                        // SizedBox(height: 8.h),
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
                        SizedBox(height: 6.h),
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
                        SizedBox(height: 6.h),
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
                      onPressed: () async {
                        if (selectedDate == null ||
                            selectedFrom == null ||
                            selectedTo == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Please complete all fields"),
                            ),
                          );
                          return;
                        }

                        // Build DateTime objects
                        final fromDate = DateTime(
                          selectedDate!.year,
                          selectedDate!.month,
                          selectedDate!.day,
                          selectedFrom!.hour,
                          selectedFrom!.minute,
                        );

                        final toDate = DateTime(
                          selectedDate!.year,
                          selectedDate!.month,
                          selectedDate!.day,
                          selectedTo!.hour,
                          selectedTo!.minute,
                        );

                        // extra safety: ensure from < to
                        if (!fromDate.isBefore(toDate)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "End time must be after start time.",
                              ),
                            ),
                          );
                          return;
                        }

                        // call provider to book on server
                        final success = await Provider.of<DeviceProvider>(
                          context,
                          listen: false,
                        ).bookDeviceOnServer(deviceName, {
                          'from': fromDate,
                          'to': toDate,
                          'date': selectedDate,
                          'notes': notesController.text,
                        });

                        if (success) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Booked successfully")),
                          );
                        } else {
                          await Provider.of<DeviceProvider>(
                            context,
                            listen: false,
                          ).fetchDevices();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Booking failed — maybe already booked or RLS denied",
                              ),
                            ),
                          );
                        }
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

 void _showReportDialog(BuildContext parentContext, String deviceName) {
  final TextEditingController reasonCtrl = TextEditingController();

  showDialog(
    context: parentContext,
    builder: (dialogContext) => AlertDialog(
      title: Text("Report Issue for $deviceName"),
      content: TextField(
        controller: reasonCtrl,
        decoration: InputDecoration(
          labelText: "Reason",
          hintText: "e.g. No display / Keyboard broken",
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text("Cancel")),
        ElevatedButton(
          onPressed: () async {
            final reason = reasonCtrl.text.trim();
            if (reason.isEmpty) {
              // Use parentContext (NOT dialogContext) to show SnackBar
              ScaffoldMessenger.of(parentContext).showSnackBar(
                SnackBar(content: Text("Please enter a reason"))
              );
              return;
            }

            // close dialog using dialogContext
            Navigator.pop(dialogContext);

            // call provider using parentContext
            final ok = await Provider.of<DeviceProvider>(parentContext, listen: false)
                .reportIssueOnServer(deviceName, reason);

            // show result using parentContext
            if (ok) {
              ScaffoldMessenger.of(parentContext).showSnackBar(
                SnackBar(content: Text("Reported — thank you"))
              );
            } else {
              ScaffoldMessenger.of(parentContext).showSnackBar(
                SnackBar(content: Text("Report failed"))
              );
            }
          },
          child: Text("Report"),
        ),
      ],
    ),
  );
}


  Widget _deviceBox(BuildContext context, Map<String, dynamic> device) {
    String status = (device["status"] ?? 'available').toString();
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

    // grab notes (may be null / empty)
    final notes = (device['notes'] ?? '').toString().trim();

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
              // Device name
              Text(
                device["name"] ?? '',
                style: TextStyle(
                  color: txt,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),

              // Lab name (if exists)
              if ((device['lab_name'] ?? '').toString().isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 6.h, bottom: 4.h),
                  child: Text(
                    device['lab_name'].toString(),
                    style: TextStyle(
                      color: AppColor.textPrimary.withOpacity(0.9),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              SizedBox(height: 5.h),

              // status text
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
                      "By: ${device["student"] ?? 'Unknown'}",
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColor.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "From ${_formatDisplay(device["from"])} - To ${_formatDisplay(device["to"])}",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColor.textPrimary.withOpacity(0.8),
                      ),
                    ),
                    // show notes if present
                    if (notes.isNotEmpty) ...[
                      SizedBox(height: 6.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          notes,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColor.textPrimary.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

              if (status == "not_working")
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device["reason"] ?? 'Reported issue',
                      style: TextStyle(color: AppColor.repair, fontSize: 11.sp),
                    ),
                    if (notes.isNotEmpty) ...[
                      SizedBox(height: 6.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          notes,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColor.textPrimary.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              SizedBox(height: 10.h),
              // small action row: Report / Release (only show Report when available or booked)
              Align(
                alignment: Alignment.bottomRight,
                child: InkWell(
                  onTap: () {
                    _showReportDialog(context, device['name']);
                  },
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Report",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 5.w),
                          // Report button (always available)
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            icon: Icon(
                              Icons.report_problem,
                              size: 18.sp,
                              color: AppColor.repair,
                            ),
                            onPressed:
                                () =>
                                    _showReportDialog(context, device['name']),
                            tooltip: 'Report issue',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDisplay(dynamic isoOrString) {
    if (isoOrString == null) return '';
    try {
      final dt = DateTime.parse(isoOrString.toString());
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $ampm';
    } catch (_) {
      return isoOrString.toString();
    }
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

    // افصل الأجهزة على شكل أزواج (نفس UI القديم)
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
