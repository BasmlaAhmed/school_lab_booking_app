import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../util/app_color.dart';
import '../../viewmodel/super_admin_view_mode.dart';
import 'super_admin_device_screen.dart';
import 'super_admin_profile_screen.dart';

class SuperAdminLabsScreen extends StatefulWidget {
  const SuperAdminLabsScreen({super.key});

  @override
  State<SuperAdminLabsScreen> createState() => _SuperAdminLabsScreenState();
}

class _SuperAdminLabsScreenState extends State<SuperAdminLabsScreen> {
  final SupabaseService _service = SupabaseService();

  List<Map<String, dynamic>> _filterAndSort(List<dynamic> raw) {
    final labs = raw.cast<Map<String, dynamic>>().toList();
    // تأكد من الترتيب الأبجدي
    labs.sort(
      (a, b) => (a['name'] ?? '').toString().toLowerCase().compareTo(
        (b['name'] ?? '').toString().toLowerCase(),
      ),
    );
    return labs;
  }

  Widget _buildLabCard(BuildContext context, Map<String, dynamic> lab) {
    final name = (lab['name'] ?? 'Unnamed Lab').toString();

    // initials
    final initials =
        name
            .split(' ')
            .where((s) => s.isNotEmpty)
            .map((s) => s[0])
            .take(2)
            .join();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) =>
                      SuperAdminDevicesScreen(labId: lab['id'], labName: name),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22.r,
                backgroundColor: Colors.blue.shade700,
                child: Text(
                  initials.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    // هنا نحسب الأرقام باستدعاء getDevicesForLab لكل لاب
                    FutureBuilder(
                      future: _service.getDevicesForLab(lab['id']),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return Row(
                            children: [
                              SizedBox(
                                width: 14.w,
                                height: 14.h,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Loading devices...',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          );
                        }

                        if (snap.hasError || snap.data == null) {
                          return Text(
                            'Devices: -  •  Not working: -',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey[600],
                            ),
                          );
                        }

                        final devices = List<Map<String, dynamic>>.from(
                          snap.data as List,
                        );
                        final total = devices.length;
                        final notWorking =
                            devices.where((d) {
                              final s =
                                  d['status']?.toString().trim().toLowerCase();
                              return s != null && s == 'not_working';
                            }).length;

                        return Row(
                          children: [
                            _buildStatBadge('$total', 'Devices'),
                            SizedBox(width: 8.w),
                            _buildStatBadge(
                              '$notWorking',
                              'Not working',
                              isWarning: notWorking > 0,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Grid card variant for larger screens (compact)
  Widget _buildLabGridCard(BuildContext context, Map<String, dynamic> lab) {
    final name = (lab['name'] ?? 'Unnamed Lab').toString();
    final initials =
        name
            .split(' ')
            .where((s) => s.isNotEmpty)
            .map((s) => s[0])
            .take(2)
            .join();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) =>
                      SuperAdminDevicesScreen(labId: lab['id'], labName: name),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundColor: Colors.blue.shade700,
                child: Text(
                  initials.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                name,
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8.h),
              // counts
              FutureBuilder(
                future: _service.getDevicesForLab(lab['id']),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return Row(
                      children: [
                        SizedBox(
                          width: 14.w,
                          height: 14.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Loading...',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    );
                  }
                  if (snap.hasError || snap.data == null) {
                    return Text(
                      'Devices: -  •  Not working: -',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[600],
                      ),
                    );
                  }
                  final devices = List<Map<String, dynamic>>.from(
                    snap.data as List,
                  );
                  final total = devices.length;
                  final notWorking =
                      devices.where((d) {
                        final s = d['status']?.toString().trim().toLowerCase();
                        return s != null && s == 'not_working';
                      }).length;
                  return Row(
                    children: [
                      _buildStatBadge('$total', 'Devices'),
                      SizedBox(width: 8.w),
                      _buildStatBadge(
                        '$notWorking',
                        'Not working',
                        isWarning: notWorking > 0,
                      ),
                    ],
                  );
                },
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge(String value, String label, {bool isWarning = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isWarning ? Colors.red.shade100 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: isWarning ? Colors.red.shade700 : Colors.black,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // افتراض أنك فعلت ScreenUtilInit في main.dart
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Labs',
          style: TextStyle(fontSize: 25.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      actions: [
  // ===== REFRESH BUTTON =====
  IconButton(
    tooltip: "Refresh Labs",
    icon: Icon(
      Icons.refresh,
      color: AppColor.primaryDark,
      size: 26,
    ),
    onPressed: () async {
      setState(() {}); // يعمل إعادة بناء للواجهة

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Refreshed")),
      );
    },
  ),

  SizedBox(width: 6.w),

  // ===== PROFILE BUTTON =====
  Padding(
    padding: EdgeInsets.only(right: 12.w),
    child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SuperAdminProfileScreen()),
        );
      },
      child: CircleAvatar(
        radius: 18.r,
        backgroundColor: AppColor.primaryDark.withOpacity(0.1),
        child: Icon(
          Icons.person,
          color: AppColor.primaryDark,
          size: 22.sp,
        ),
      ),
    ),
  ),
],


      ),
      body: SafeArea(
        child: FutureBuilder(
          future: _service.getAllLabs(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading labs',
                  style: TextStyle(fontSize: 14.sp),
                ),
              );
            }

            final raw = snapshot.data;
            if (raw == null || (raw is List && raw.isEmpty)) {
              return Center(
                child: Text('No labs found', style: TextStyle(fontSize: 14.sp)),
              );
            }

            final labs = _filterAndSort(raw);

            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                // responsive: list on narrow, grid on wider
                if (width >= 1100) {
                  final crossAxis = 4;
                  return GridView.builder(
                    padding: EdgeInsets.all(12.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxis,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: labs.length,
                    itemBuilder:
                        (context, index) =>
                            _buildLabGridCard(context, labs[index]),
                  );
                } else if (width >= 700) {
                  final crossAxis = 3;
                  return GridView.builder(
                    padding: EdgeInsets.all(12.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxis,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: labs.length,
                    itemBuilder:
                        (context, index) =>
                            _buildLabGridCard(context, labs[index]),
                  );
                } else if (width >= 450) {
                  final crossAxis = 2;
                  return GridView.builder(
                    padding: EdgeInsets.all(12.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxis,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 2.8,
                    ),
                    itemCount: labs.length,
                    itemBuilder:
                        (context, index) => _buildLabCard(context, labs[index]),
                  );
                } else {
                  // narrow screens: list
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    itemCount: labs.length,
                    itemBuilder:
                        (context, index) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 6.h),
                          child: _buildLabCard(context, labs[index]),
                        ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
