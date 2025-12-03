import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../viewmodel/super_admin_view_mode.dart';

class SuperAdminDevicesScreen extends StatefulWidget {
  final String labId;
  final String labName;

  const SuperAdminDevicesScreen({
    super.key,
    required this.labId,
    required this.labName,
  });

  @override
  State<SuperAdminDevicesScreen> createState() =>
      _SuperAdminDevicesScreenState();
}

class _SuperAdminDevicesScreenState extends State<SuperAdminDevicesScreen> {
  final SupabaseService _service = SupabaseService();

  @override
  Widget build(BuildContext context) {
    // تأكد أن ScreenUtil.init تم استدعاؤه أعلى في الهرمية (main.dart)
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Text(
          widget.labName,
          style: TextStyle(fontSize: 25.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _service.getDevicesForLab(widget.labId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading devices"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No devices found"));
          }

          final devices = snapshot.data!;

          return LayoutBuilder(
            builder: (context, constraints) {
              // Responsive crossAxisCount based on available width
              int crossAxisCount;
              double width = constraints.maxWidth;

              if (width >= 1200) {
                crossAxisCount = 4;
              } else if (width >= 900) {
                crossAxisCount = 3;
              } else if (width >= 600) {
                crossAxisCount = 2;
              } else {
                crossAxisCount = 2;
              }

              // childAspectRatio يعتمد على نسبة العرض للارتفاع المطلوبة
              final childAspectRatio = (width / crossAxisCount) / (180.h);

              return GridView.builder(
                padding: EdgeInsets.all(12.w),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];

                  final String deviceName = device['name'] ?? "Unknown Device";
                  final rawStatus =
                      device['status']?.toString().trim().toLowerCase();

                  String status;
                  if (rawStatus == "available") {
                    status = "available";
                  } else if (rawStatus == "not_working") {
                    status = "not_working";
                  } else {
                    status = "not_working";
                  }

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            deviceName,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            "Status: $status",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color:
                                  status == "available"
                                      ? Colors.green
                                      : Colors.red,
                            ),
                          ),
                          const Spacer(),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: DropdownButton<String>(
                              value: status,
                              // صغيرة: نخلي حجم النص مناسب للشاشة
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.black,
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: "available",
                                  child: Text(
                                    "Available",
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: "not_working",
                                  child: Text(
                                    "Not Working",
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                ),
                              ],
                              onChanged: (value) async {
                                if (value == null) return;
                                await _service.updateDeviceStatus(
                                  device['id'],
                                  value,
                                );
                                setState(() {});
                              },
                              iconSize: 20.sp,
                              isDense: true,
                              underline: SizedBox(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
