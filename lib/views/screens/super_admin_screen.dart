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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

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
      elevation: isDark ? 1 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      color: theme.cardColor,
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
                backgroundColor:
                    isDark
                        ? AppColor.primarylight
                        : AppColor.primaryDark, // theme primary
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
                        color: cs.onSurface,
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: cs.primary,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Loading devices...',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: cs.onSurface.withOpacity(0.7),
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
                              color: cs.onSurface.withOpacity(0.7),
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
                            _buildStatBadge(context, '$total', 'Devices'),
                            SizedBox(width: 8.w),
                            _buildStatBadge(
                              context,
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
                color: cs.onSurface.withOpacity(0.65),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Grid card variant for larger screens (compact)
  Widget _buildLabGridCard(BuildContext context, Map<String, dynamic> lab) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

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
      color: theme.cardColor,
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
                backgroundColor: cs.primary,
                child: Text(
                  initials.toUpperCase(),
                  style: TextStyle(
                    color: cs.onPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                name,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
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
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.primary,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Loading...',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: cs.onSurface.withOpacity(0.7),
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
                        color: cs.onSurface.withOpacity(0.7),
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
                      _buildStatBadge(context, '$total', 'Devices'),
                      SizedBox(width: 8.w),
                      _buildStatBadge(
                        context,
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
                  color: cs.onSurface.withOpacity(0.65),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge(
    BuildContext context,
    String value,
    String label, {
    bool isWarning = false,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bg =
        isWarning
            ? (isDark ? cs.error.withOpacity(0.18) : Colors.red.shade100)
            : (isDark ? cs.surfaceVariant : Colors.grey.shade200);

    final textColor =
        isWarning
            ? (isDark ? Colors.red.shade100 : Colors.red.shade700)
            : cs.onSurface;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: cs.onSurface.withOpacity(0.75),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // افتراض أنك فعلت ScreenUtilInit في main.dart
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: cs.onBackground),
        title: Text(
          'Labs',
          style: TextStyle(
            fontSize: 25.sp,
            fontWeight: FontWeight.bold,
            color: cs.onBackground,
          ),
        ),
        centerTitle: true,
        actions: [
          // ===== REFRESH BUTTON =====
          IconButton(
            tooltip: "Refresh Labs",
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).colorScheme.onBackground,
              size: 26.sp,
            ),
            onPressed: () async {
              setState(() {}); // يعمل إعادة بناء للواجهة

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Refreshed")));
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
                backgroundColor: cs.primary.withOpacity(0.12),
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.onBackground,
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
              return Center(
                child: CircularProgressIndicator(color: cs.primary),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading labs',
                  style: TextStyle(fontSize: 14.sp, color: cs.onSurface),
                ),
              );
            }

            final raw = snapshot.data;
            if (raw == null || (raw is List && raw.isEmpty)) {
              return Center(
                child: Text(
                  'No labs found',
                  style: TextStyle(fontSize: 14.sp, color: cs.onSurface),
                ),
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
