// viewmodel/device_provider.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

/// DeviceProvider محدث ليتوافق مع أعمدة جدول Devices الموجود عندك
/// ويقوم بتحرير الأجهزة أوتوماتيكياً عندما ينتهي وقت الحجز (to_time).
class DeviceProvider with ChangeNotifier {
  Map<String, Map<String, dynamic>> devices = {};

  final String devicesTable;
  final String usersTable;
  final String labsTable;

  DeviceProvider({
    this.devicesTable = 'Devices',
    this.usersTable = 'Users',
    this.labsTable = 'Labs',
    bool autoFetch = true,
  }) {
    if (autoFetch) fetchDevices();
  }

  void _d(String msg) {
    if (kDebugMode) debugPrint(msg);
  }

  /// Fetch devices — robust version + auto-release expired bookings
  Future<void> fetchDevices() async {
    try {
      final currentUser = supabase.auth.currentUser;
      _d('DEBUG fetchDevices — currentUser: ${currentUser?.id ?? 'NULL (not logged)'}');

      // 1) SELECT الحقول الموجودة عندك
      final simpleResp = await supabase.from(devicesTable).select(
        'id, name, lab_id, status, booked_by, from_time, to_time',
      ).order('name', ascending: true);

      _d('DEBUG simple select raw: $simpleResp');

      if (simpleResp == null || (simpleResp is List && simpleResp.isEmpty)) {
        _d('DEBUG: simple select returned no rows or null');
        devices = {};
        notifyListeners();
        return;
      }

      final List<dynamic> rows = (simpleResp is List) ? List<dynamic>.from(simpleResp) : [simpleResp];

      // 2) نجمع booked_by ids و lab_ids لنحل أسمائهم دفعة واحدة
      final Set<String> userIds = <String>{};
      final Set<String> labIds = <String>{};
      for (final row in rows) {
        try {
          final b = row['booked_by'];
          final lid = row['lab_id'];
          if (b != null) userIds.add(b.toString());
          if (lid != null) labIds.add(lid.toString());
        } catch (_) {}
      }

      // 3) batch fetch للأسماء (users)
      final Map<String, String> userIdToName = {};
      if (userIds.isNotEmpty) {
        try {
          final usersResp = await supabase
              .from(usersTable)
              .select('id, name')
              .filter('id', 'in', userIds.toList());

          _d('DEBUG usersResp: $usersResp');

          if (usersResp is List) {
            for (final u in usersResp) {
              if (u != null && u['id'] != null) {
                userIdToName[u['id'].toString()] = (u['name']?.toString() ?? u['id'].toString());
              }
            }
          }
        } catch (e) {
          _d('DEBUG users batch fetch failed: $e');
        }
      }

      // 4) batch fetch للأسماء (labs)
      final Map<String, String> labIdToName = {};
      if (labIds.isNotEmpty) {
        try {
          final labsResp = await supabase
              .from(labsTable)
              .select('id, name')
              .filter('id', 'in', labIds.toList());

          _d('DEBUG labsResp: $labsResp');

          if (labsResp is List) {
            for (final l in labsResp) {
              if (l != null && l['id'] != null) {
                labIdToName[l['id'].toString()] = (l['name']?.toString() ?? l['id'].toString());
              }
            }
          }
        } catch (e) {
          _d('DEBUG labs batch fetch failed: $e');
        }
      }

      // 5) بناء الخريطة بالشكل الذي يتوقعه UI
      final Map<String, Map<String, dynamic>> mapped = {};
      for (final item in rows) {
        try {
          final name = (item['name'] ?? '').toString();
          if (name.isEmpty) continue;

          final bookedById = item['booked_by']?.toString();
          final bookedByName = bookedById != null ? (userIdToName[bookedById] ?? bookedById) : null;
          final labId = item['lab_id']?.toString();
          final labName = labId != null ? (labIdToName[labId] ?? '') : '';

          mapped[name] = {
            'id': item['id'],
            'name': name,
            'lab_id': item['lab_id'],
            'lab_name': labName,
            'status': item['status'] ?? 'available',
            'student': bookedByName,
            'from': item['from_time']?.toString(),
            'to': item['to_time']?.toString(),
          };
        } catch (e) {
          _d('DEBUG mapping row failed: $e — row: $item');
        }
      }

      // 6) AUTO-RELEASE: لو انتهى الوقت (to_time) نعمل update على السجل ليصبح available
      final now = DateTime.now().toUtc(); // نستخدم UTC لمطابقة ISO timestamps
      bool performedRelease = false;

      for (final deviceEntry in mapped.entries) {
        final device = deviceEntry.value;
        try {
          final status = (device['status'] ?? '').toString();
          final toValue = device['to'];
          if (status == 'booked' && toValue != null) {
            DateTime? end;
            // حاول نحلل string إلى DateTime بأمان
            try {
              end = DateTime.parse(toValue.toString());
            } catch (_) {
              // لو parse فشل، جرب لو هو مجرد وقت (مثل "14:00"), فنتجاهل هنا
              end = null;
            }

            if (end != null) {
              // نطابق المناطق الزمنية: إذا الـ end بدون offset، DateTime.parse غالبا يرجعه كـ local.
              // لذلك نحوّله إلى UTC لمقارنة صحيحة.
              final endUtc = end.toUtc();
              if (now.isAfter(endUtc)) {
                // وقت الحجز خلص → حرر الجهاز في DB
                try {
                  await supabase.from(devicesTable).update({
                    'status': 'available',
                    'booked_by': null,
                    'from_time': null,
                    'to_time': null,
                  }).eq('id', device['id']);
                  performedRelease = true;
                  _d('Auto-released device id=${device['id']} (to_time was $toValue)');
                } catch (e) {
                  _d('Auto-release update failed for id=${device['id']}: $e');
                }
              }
            }
          }
        } catch (e) {
          _d('Error checking auto-release for device ${deviceEntry.key}: $e');
        }
      }

      if (performedRelease) {
        // لو عملنا تحديث واحد على الأقل، نعيد جلب البيانات مرة ثانية لتحديث الـ UI
        _d('Performed auto-release — refetching devices');
        await fetchDevices(); // لاحظ: ستكون نهاية لأن الآن لن توجد أجهزة منتهية
        return;
      }

      // لو ما حصلش release، نخزن الخريطة ونعلم الواجهه
      devices = mapped;
      _d('DEBUG mapped devices keys: ${devices.keys.toList()}');
      notifyListeners();
    } catch (e, st) {
      _d('fetchDevices error: $e\n$st');
      devices = {};
      notifyListeners();
    }
  }

  /// Book device on server — يحدّث الحقول الموجودة فقط
  Future<bool> bookDeviceOnServer(String deviceName, Map<String, dynamic> bookingData) async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        _d('Booking failed: no authenticated user');
        return false;
      }

      String? fromIso;
      String? toIso;

      if (bookingData['from'] is DateTime) {
        fromIso = (bookingData['from'] as DateTime).toUtc().toIso8601String();
      } else if (bookingData['from'] is String) {
        fromIso = bookingData['from'];
      }

      if (bookingData['to'] is DateTime) {
        toIso = (bookingData['to'] as DateTime).toUtc().toIso8601String();
      } else if (bookingData['to'] is String) {
        toIso = bookingData['to'];
      }

      final updates = <String, dynamic>{
        'status': 'booked',
        'booked_by': currentUser.id,
        'from_time': fromIso,
        'to_time': toIso,
      };

      await supabase.from(devicesTable).update(updates).eq('name', deviceName);
      await fetchDevices();
      return true;
    } on PostgrestException catch (e) {
      _d('Booking PostgrestException: ${e.message}');
      return false;
    } catch (e) {
      _d('Booking unexpected error: $e');
      return false;
    }
  }

  /// Release device (set available)
  Future<bool> releaseDeviceOnServer(String deviceName) async {
    try {
      await supabase.from(devicesTable).update({
        'status': 'available',
        'booked_by': null,
        'from_time': null,
        'to_time': null,
      }).eq('name', deviceName);

      await fetchDevices();
      return true;
    } catch (e) {
      _d('Release error: $e');
      return false;
    }
  }
  /// Report issue on server (mark not_working + reason)
Future<bool> reportIssueOnServer(String deviceName, String reason) async {
  try {
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      _d('Report failed: no authenticated user');
      return false;
    }

    // أسماء الأعمدة المحتملة — ضيفي/حمّلي حسب schema عندك
    final candidateColumns = ['reason', 'notes', 'issue', 'problem', 'description', 'report_reason'];

    PostgrestException? lastPostgresEx;

    for (final col in candidateColumns) {
      try {
        final updates = <String, dynamic>{
          'status': 'not_working',
          col: reason,
          // حاول تحدّث الحقول المرتبطة بالمبلّغ لو موجودة
          'reported_by': currentUser.id,
        };

        // محاولة التحديث
        await supabase.from(devicesTable).update(updates).eq('name', deviceName);

        // لو وصل هنا، التحديث نجح
        await fetchDevices();
        _d('reportIssueOnServer: updated column "$col" successfully for $deviceName');
        return true;
      } on PostgrestException catch (e) {
        lastPostgresEx = e;
        _d('reportIssueOnServer: attempt with column "$col" failed: ${e.message}');
        // إذا الرسالة واضحة إن العمود غير موجود نجرب الاسم التالي
      }
    }

    // لو وصلنا هنا كل المحاولات فشلت
    _d('reportIssueOnServer: all candidate columns failed. Last PostgresException: ${lastPostgresEx?.message}');
    return false;
  } catch (e) {
    _d('Report issue unexpected error: $e');
    return false;
  }
}

}
