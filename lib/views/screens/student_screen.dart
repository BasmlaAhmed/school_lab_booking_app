import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../util/app_color.dart';
import '../../viewmodel/device_provider.dart';
import 'student_profile_screen.dart';

class StudentScreen extends StatefulWidget {
  final String labId;
  const StudentScreen({super.key, required this.labId});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  Map<String, Timer> timers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DeviceProvider>(
        context,
        listen: false,
      ).fetchDevices(labId: widget.labId);
    });
  }

  // ---------- dialogs & helpers (unchanged) ----------
  void _showBookingDialog(
    BuildContext context,
    String deviceName,
    Map<String, dynamic> deviceData,
  ) async {
    final TextEditingController notesController = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedFrom;
    TimeOfDay? selectedTo;

    final status = (deviceData['status'] ?? 'available').toString();
    if (status == 'not_working') return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            "Book $deviceName",
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium!.color,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            height: 135.h,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setStateDialog(() => selectedDate = picked);
                    }
                  },
                  child: Text(
                    selectedDate == null
                        ? "Select Date"
                        : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) {
                      setStateDialog(() => selectedFrom = picked);
                    }
                  },
                  child: Text(
                    selectedFrom == null
                        ? "Select Start Time"
                        : "From: ${selectedFrom!.format(context)}",
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) {
                      setStateDialog(() => selectedTo = picked);
                    }
                  },
                  child: Text(
                    selectedTo == null
                        ? "Select End Time"
                        : "To: ${selectedTo!.format(context)}",
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
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
                    const SnackBar(
                      content: Text("Please complete all fields"),
                    ),
                  );
                  return;
                }

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

                if (!fromDate.isBefore(toDate)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "End time must be after start time.",
                      ),
                    ),
                  );
                  return;
                }

                final deviceProvider =
                    Provider.of<DeviceProvider>(context, listen: false);

                final success =
                    await deviceProvider.bookDeviceOnServer(deviceName, {
                  'from': fromDate.toIso8601String(),
                  'to': toDate.toIso8601String(),
                  'notes': notesController.text,
                });

                await deviceProvider.fetchDevices(); // ← التحديث الفوري
                setState(() {}); // ← إعادة بناء الشاشة فورًا

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? "Booked successfully" : "Booking failed",
                    ),
                  ),
                );
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

  void _showReportDialog(BuildContext context, String deviceName) async {
    final TextEditingController otherController = TextEditingController();
    String? selectedIssue;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text("Report Issue for $deviceName"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedIssue,
                hint: const Text('Select issue type'),
                isExpanded: true,
                items: [
                  'Mouse issue',
                  'Keyboard issue',
                  'Cable issue',
                  'Others',
                ]
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  setStateDialog(() => selectedIssue = val);
                },
              ),
              if (selectedIssue == 'Others')
                TextField(
                  controller: otherController,
                  decoration: const InputDecoration(
                    hintText: 'Describe the issue',
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedIssue == null ||
                    (selectedIssue == 'Others' &&
                        otherController.text.trim().isEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Please provide issue type or description",
                      ),
                    ),
                  );
                  return;
                }

                final reason = selectedIssue == 'Others'
                    ? otherController.text.trim()
                    : selectedIssue!;

                Navigator.pop(dialogContext);

                final ok = await Provider.of<DeviceProvider>(
                  context,
                  listen: false,
                ).reportIssueOnServer(deviceName, reason);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok ? "Reported — thank you" : "Report failed",
                    ),
                  ),
                );
              },
              child: const Text(
                "Report",
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildBookedLine({
    required String studentName,
    required String studentEmail,
    required dynamic from,
    required dynamic to,
  }) {
    final who = studentName.isNotEmpty
        ? studentName
        : (studentEmail.isNotEmpty ? studentEmail : 'Another student');
    final fromStr = _formatDisplay(from);
    final toStr = _formatDisplay(to);
    if (fromStr.isEmpty || toStr.isEmpty) return "Booked by $who";
    return "Booked by $who ($fromStr - $toStr)";
  }

  bool _isReasonValid(String? reason) {
    if (reason == null) return false;
    final r = reason.trim();
    if (r.isEmpty) return false;

    const allowed = {'Mouse issue', 'Keyboard issue', 'Cable issue', 'Others'};
    if (allowed.contains(r)) return true;

    return r.length >= 3; // تجاهل قيم قصيرة جدًا
  }

  Widget _deviceBox(BuildContext context, Map<String, dynamic> device) {
    final status = (device['status'] ?? 'available').toString();
    final labName = (device['lab_name'] ?? '').toString().trim();
    final rawReason = (device['reason'] ?? '').toString().trim();
    final reason = _isReasonValid(rawReason) ? rawReason : null;
    final studentName = (device['student_name'] ?? '').toString().trim();
    final studentEmail = (device['student_email'] ?? '').toString().trim();

    Color bg = Theme.of(context).cardColor;
    Color border = Theme.of(context).dividerColor;

    if (status == "booked") {
      bg = AppColor.booked.withOpacity(0.3);
      border = AppColor.booked;
    } else if (status == "not_working") {
      bg = AppColor.repair.withOpacity(0.3);
      border = AppColor.repair;
    }

    final canTapToBook = status == "available";

    return Expanded(
      child: InkWell(
        onTap: canTapToBook
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
                device["name"] ?? '',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                ),
              ),
              SizedBox(height: 4.h),
              if (labName.isNotEmpty)
                Text(
                  "Lab: $labName",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                ),
              SizedBox(height: 4.h),
              if (status == "available")
                Text(
                  "Available",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                )
              else if (status == "booked")
                Text(
                  _buildBookedLine(
                    studentName: studentName,
                    studentEmail: studentEmail,
                    from: device['from'],
                    to: device['to'],
                  ),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                )
              else
                Text(
                  "Not Working",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                ),
              if ((status == 'not_working' ||
                      (status != 'not_working' && reason != null)) &&
                  reason != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(6.r),
                  margin: EdgeInsets.only(top: 5.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    "Issue: $reason",
                    style: TextStyle(fontSize: 12.sp),
                  ),
                ),
              if (status != "not_working")
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton.icon(
                    onPressed: () => _showReportDialog(context, device['name']),
                    icon: Icon(
                      Icons.report_problem,
                      color: Colors.red,
                      size: 18.w,
                    ),
                    label: Text(
                      "Report",
                      style: TextStyle(color: Colors.red, fontSize: 13.sp),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // empty box shown when a letter has only one device
  Widget _emptyDeviceBox(BuildContext context) {
    final Color visibleBg = Colors.grey.shade200;
    final Color border = Theme.of(context).dividerColor;
    final Color hintColor = Theme.of(
      context,
    ).textTheme.bodyMedium!.color!.withOpacity(0.5);

    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.r),
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        decoration: BoxDecoration(
          color: visibleBg,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: border),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.device_unknown_outlined,
                size: 26.sp,
                color: hintColor,
              ),
              SizedBox(height: 6.h),
              Text(
                'Empty',
                style: TextStyle(fontSize: 13.sp, color: hintColor),
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
      final dt = DateTime.parse(isoOrString.toString()); // بدون toLocal
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $ampm';
    } catch (_) {
      return isoOrString.toString();
    }
  }

  // pair container now puts the cellLabel inside the big card
  Widget _pairContainer(
    BuildContext context,
    List<Map<String, dynamic>> pair,
    int index,
    String cellLabel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 اسم السيل فوق الكارد — نفس الستايل القديم بالظبط
        Padding(
          padding: EdgeInsets.only(left: 6.w, bottom: 8.h),
          child: Text(
            cellLabel,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium!.color,
            ),
          ),
        ),

        // 🔹 الكارد الكبير
        Container(
          margin: EdgeInsets.only(bottom: 15.h),
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            color: Theme.of(context).cardColor,
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            children: [
              _deviceBox(context, pair[0]),
              pair.length > 1
                  ? _deviceBox(context, pair[1])
                  : _emptyDeviceBox(context),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceProvider = Provider.of<DeviceProvider>(context);

    // ------------- GROUPING LOGIC -------------
    // devices map: key is device name like "A1", value is map of device data
    final Map<String, dynamic> rawDevices = deviceProvider.devices;

    // 1) group by first letter
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    rawDevices.forEach((key, value) {
      if (key == null) return;
      final name = key.toString();
      if (name.isEmpty) return;
      final letter = name[0].toUpperCase();
      grouped.putIfAbsent(letter, () => []);
      grouped[letter]!.add({'name': name, ...value});
    });

    // 2) sort letters A..Z
    final sortedLetters = grouped.keys.toList()..sort();

    // 3) for each letter, sort its devices by numeric suffix (if present) then create pairs
    List<List<Map<String, dynamic>>> devicePairs = [];
    int cellIndex = 0;
    for (final letter in sortedLetters) {
      final list = grouped[letter]!;

      // sort by number after the letter, fallback to name
      list.sort((a, b) {
        final na = a['name'] as String;
        final nb = b['name'] as String;
        int parseNum(String s) {
          final rest = s.length > 1 ? s.substring(1) : '';
          final n = int.tryParse(rest) ?? 0;
          return n;
        }

        final naNum = parseNum(na);
        final nbNum = parseNum(nb);
        if (naNum != nbNum) return naNum.compareTo(nbNum);
        return na.compareTo(nb);
      });

      // now make pairs inside this letter group
      for (int i = 0; i < list.length; i += 2) {
        if (i + 1 < list.length) {
          devicePairs.add([list[i], list[i + 1]]);
        } else {
          // single leftover -> pair with a dummy placeholder map
          devicePairs.add([list[i]]); // _pairContainer will render empty second
        }
      }
    }

    // ---------------- compute lab display name ----------------
    String labDisplayName() {
      // try to find lab_name from any device
      try {
        for (final v in rawDevices.values) {
          if (v is Map && v.containsKey('lab_name')) {
            final ln = (v['lab_name'] ?? '').toString().trim();
            if (ln.isNotEmpty) return ln;
          }
        }
      } catch (_) {}
      // fallback: you can return widget.labId or a default label
      return ' ';
    }

    final headerTitle = labDisplayName();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).textTheme.bodyMedium!.color,
          ),
        ),
        
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).textTheme.bodyMedium!.color,
            ),
            onPressed: () async {
              final deviceProvider =
                  Provider.of<DeviceProvider>(context, listen: false);

              await deviceProvider.fetchDevices(labId: widget.labId);
              setState(() {});

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Refreshed")),
              );
            },
          ),
          
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The large title now shows the lab name too (keeps previous style)
            Text(
              headerTitle,
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyMedium!.color,
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: devicePairs.isEmpty
                  ? const Center(child: Text("No devices found"))
                  : ListView.builder(
                      itemCount: devicePairs.length,
                      itemBuilder: (context, index) {
                        // compute a readable cell label: use the letter of the first device
                        final first = devicePairs[index][0];
                        final letter = (first['name'] as String).isNotEmpty
                            ? (first['name'] as String)[0].toUpperCase()
                            : '';
                        final cellLabel = 'Cell $letter';
                        return _pairContainer(
                          context,
                          devicePairs[index],
                          index,
                          cellLabel,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
