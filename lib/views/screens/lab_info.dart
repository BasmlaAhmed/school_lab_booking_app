import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart' as p;
import 'package:provider/provider.dart';
import '../../model/lab_model.dart';
import '../../util/app_color.dart';
import '../../viewmodel/lab_provider.dart';
import '../../viewmodel/theme_provider.dart';

class LabInfo extends StatefulWidget {
  final String labId; // ← مهم: ID اللاب من Supabase
  final String labName;
  final Map<String, dynamic> labData;
  final String engineerName;

  const LabInfo({
    super.key,
    required this.labId,
    required this.labName,
    required this.labData,
    required this.engineerName, required LabModel lab,
  });

  @override
  State<LabInfo> createState() => _LabInfoState();
}

class _LabInfoState extends State<LabInfo> {
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  final TextEditingController classController = TextEditingController();
  Timer? timer;

  /// -------- Helper to convert Date + Time to ISO String (local -> UTC) ----------
  String _buildIsoDateTimeUtc(DateTime date, TimeOfDay time) {
    final dtLocal = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    return dtLocal.toUtc().toIso8601String();
  }

  /// -------- Pickers ----------
  Future<void> pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (date != null) setState(() => selectedDate = date);
  }

  Future<void> pickStartTime() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: startTime ?? TimeOfDay.now(),
    );
    if (time != null) setState(() => startTime = time);
  }

  Future<void> pickEndTime() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: endTime ?? TimeOfDay.now(),
    );
    if (time != null) setState(() => endTime = time);
  }

  @override
  void initState() {
    super.initState();

    classController.text =
        widget.labData["className"]?.toString() ??
        widget.labData["class_name"]?.toString() ??
        "";

    /// ------- Try parse stored data (convert to local for UI) -------
    final fromTimeIso = widget.labData["from_time"] ?? widget.labData["from"];
    final toTimeIso = widget.labData["to_time"] ?? widget.labData["to"];

    if (fromTimeIso != null) {
      final dtRaw = DateTime.tryParse(fromTimeIso.toString());
      if (dtRaw != null) {
        final dt = dtRaw.toLocal();
        startTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
        selectedDate = DateTime(dt.year, dt.month, dt.day);
      } else {
        // fallback: if stored as "HH:mm"
        if (fromTimeIso is String && fromTimeIso.contains(':')) {
          final parts = fromTimeIso.split(':');
          if (parts.length >= 2) {
            startTime = TimeOfDay(
              hour: int.tryParse(parts[0]) ?? 0,
              minute: int.tryParse(parts[1]) ?? 0,
            );
          }
        }
      }
    }

    if (toTimeIso != null) {
      final dtRaw = DateTime.tryParse(toTimeIso.toString());
      if (dtRaw != null) {
        final dt = dtRaw.toLocal();
        endTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
        selectedDate ??= DateTime(dt.year, dt.month, dt.day);
      } else {
        // fallback: if stored as "HH:mm"
        if (toTimeIso is String && toTimeIso.contains(':')) {
          final parts = toTimeIso.split(':');
          if (parts.length >= 2) {
            endTime = TimeOfDay(
              hour: int.tryParse(parts[0]) ?? 0,
              minute: int.tryParse(parts[1]) ?? 0,
            );
          }
        }
      }
    }

    // If this lab is already booked and we have a date+endTime, schedule auto-release
    if ((widget.labData["status"]?.toString() ?? '') == 'booked') {
      _maybeScheduleFromStored();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    classController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) =>
      "${t.hour}:${t.minute.toString().padLeft(2, '0')}";

  /// ------------------ SCHEDULING LOGIC ------------------
  /// Try to schedule release using available stored data (to_time or date+endTime)
  void _maybeScheduleFromStored() {
    // priority: use exact stored to_time ISO if present
    final toIso = widget.labData["to_time"] ?? widget.labData["to"];
    if (toIso != null) {
      final dtRaw = DateTime.tryParse(toIso.toString());
      if (dtRaw != null) {
        final localTarget = dtRaw.toLocal();
        _scheduleReleaseAt(localTarget);
        return;
      }
    }

    // fallback: use selectedDate + endTime if both exist
    if (selectedDate != null && endTime != null) {
      final endDt = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        endTime!.hour,
        endTime!.minute,
      );
      _scheduleReleaseAt(endDt);
    }
  }

  /// Schedule a Timer to run at targetDateTime (local).
  /// It will call provider.releaseLab(...) and update local UI.
  void _scheduleReleaseAt(DateTime target) {
    timer?.cancel();
    final now = DateTime.now();
    final duration = target.difference(now);

    if (duration.inSeconds <= 0) {
      // time already passed — release immediately
      _releaseNow();
      return;
    }

    timer = Timer(duration, () async {
      await _releaseNow();
    });
  }

  /// Perform release: call provider to update DB, then update local UI.
  Future<void> _releaseNow() async {
    try {
      await p.Provider.of<LabProvider>(
        context,
        listen: false,
      ).releaseLab(widget.labId);
    } catch (e) {
      // ignore errors but print for debugging
      debugPrint('releaseNow error: $e');
    }

    if (!mounted) return;
    setState(() {
      widget.labData["status"] = "available";
      widget.labData.remove("bookedBy");
      widget.labData.remove("from");
      widget.labData.remove("to");
      widget.labData.remove("className");
      widget.labData.remove("from_time");
      widget.labData.remove("to_time");
      widget.labData.remove("date");
    });
  }

  @override
  Widget build(BuildContext context) {
    final labProvider = p.Provider.of<LabProvider>(context, listen: false);
    final labData = widget.labData;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsets.all(15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40.h),

            /// -------- Title --------
            Text(
              "${widget.labName} Details",
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColor.textPrimary,
              ),
            ),

            SizedBox(height: 20.h),

            /// -------- Lab Status Card --------
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
              elevation: 3,
              child: ListTile(
                leading: Icon(
                  Icons.computer,
                  color: AppColor.primaryDark,
                  size: 35.sp,
                ),
                title: Text(
                  labData["status"] == "available"
                      ? "Available"
                      : "Booked by ${labData["bookedBy"] ?? "Unknown"}",
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: isDark ? Colors.white : AppColor.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: labData["status"] == "available"
                    ? null
                    : Text(
                        "Class: ${labData["className"]}\n"
                        "From ${labData["from"]} to ${labData["to"]}",
                        style: TextStyle(color: Colors.red),
                      ),
              ),
            ),

            SizedBox(height: 20.h),

            /// -------- Class Input --------
            TextField(
              controller: classController,
              decoration: InputDecoration(
                labelText: "Class / Department",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),

            SizedBox(height: 20.h),

            /// -------- Pickers --------
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: pickDate,
                    child: _box(
                      selectedDate == null
                          ? "Pick Date"
                          : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                      isDark: isDark,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: GestureDetector(
                    onTap: pickStartTime,
                    child: _box(
                      startTime == null
                          ? "Start Time"
                          : _formatTime(startTime!),
                      isDark: isDark,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: GestureDetector(
                    onTap: pickEndTime,
                    child: _box(
                      endTime == null ? "End Time" : _formatTime(endTime!),
                      isDark: isDark,
                    ),
                  ),
                ),
              ],
            ),

            Spacer(),

            /// -------- BOOK BUTTON --------
            InkWell(
              onTap: () async {
                if (classController.text.isEmpty ||
                    selectedDate == null ||
                    startTime == null ||
                    endTime == null) {
                  _error("Please complete all fields");
                  return;
                }

                // -------- Build local DateTimes from pickers --------
                final localFrom = DateTime(
                  selectedDate!.year,
                  selectedDate!.month,
                  selectedDate!.day,
                  startTime!.hour,
                  startTime!.minute,
                );
                final localTo = DateTime(
                  selectedDate!.year,
                  selectedDate!.month,
                  selectedDate!.day,
                  endTime!.hour,
                  endTime!.minute,
                );

                // -------- Convert to UTC ISO for Supabase (store normalized) --------
                final fromIsoUtc = localFrom.toUtc().toIso8601String();
                final toIsoUtc = localTo.toUtc().toIso8601String();

                /// -------- Call Supabase --------
                final ok = await labProvider.bookLab(
                  widget.labId,
                  classController.text,
                  fromIsoUtc,
                  toIsoUtc,
                );

                if (!ok) {
                  _error("Booking failed. Try again.");
                  return;
                }

                /// -------- Update local UI (display uses local times) --------
                setState(() {
                  labData["status"] = "booked";
                  labData["bookedBy"] = widget.engineerName;
                  labData["className"] = classController.text;
                  labData["from"] = _formatTime(startTime!); // local display
                  labData["to"] = _formatTime(endTime!); // local display
                  labData["from_time"] = fromIsoUtc; // stored UTC
                  labData["to_time"] = toIsoUtc; // stored UTC
                  labData["date"] = selectedDate?.toIso8601String();
                });

                // schedule release at parsedTo (convert stored UTC to local for Timer)
                final parsedTo = DateTime.tryParse(toIsoUtc);
                if (parsedTo != null) {
                  _scheduleReleaseAt(parsedTo.toLocal());
                } else {
                  // fallback: schedule using selectedDate + endTime (local)
                  final fallback = DateTime(
                    selectedDate!.year,
                    selectedDate!.month,
                    selectedDate!.day,
                    endTime!.hour,
                    endTime!.minute,
                  );
                  _scheduleReleaseAt(fallback);
                }

                /// -------- Success Popup --------
                _showSuccess();
              },
              child: Container(
                height: 55.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColor.primarylight,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Center(
                  child: Text(
                    "Book Lab",
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textPrimary,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            /// -------- BACK BUTTON --------
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 55.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColor.primaryDark,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Center(
                  child: Text(
                    "Back",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- UI Helpers ----------------
  Widget _box(String text, {required bool isDark}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15.h),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: AppColor.border),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.sp,
            color: isDark ? Colors.white : AppColor.textPrimary,
          ),
        ),
      ),
    );
  }

  void _error(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _showSuccess() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          "Booking Confirmed",
          style: TextStyle(
            color: AppColor.primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Your booking for ${widget.labName} is confirmed.",
          style: TextStyle(color: AppColor.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
            child: Text(
              "OK",
              style: TextStyle(
                color: AppColor.primaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
