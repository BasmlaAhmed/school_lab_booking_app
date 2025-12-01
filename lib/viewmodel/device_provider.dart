import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class DeviceProvider with ChangeNotifier {
  Map<String, Map<String, dynamic>> devices = {};
  Timer? _timer;

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
    _startAutoReleaseTimer();
  }

  void _d(String msg) {
    if (kDebugMode) debugPrint(msg);
  }

  void _startAutoReleaseTimer() {
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkExpiredBookings(),
    );
  }

  Future<void> _checkExpiredBookings() async {
    final now = DateTime.now().toUtc();

    for (final entry in devices.entries) {
      final deviceName = entry.key;
      final device = entry.value;
      final toTimeStr = device['to'];

      if (toTimeStr != null && device['status'] == 'booked') {
        final toTime = DateTime.tryParse(toTimeStr);
        if (toTime != null && now.isAfter(toTime)) {
          try {
            await supabase
                .from(devicesTable)
                .update({
                  'status': 'available',
                  'booked_by': null,
                  'from_time': null,
                  'to_time': null,
                  'reason': null,
                  'reported_by': null,
                })
                .eq('name', deviceName);
          } catch (e) {
            _d('Error releasing device $deviceName: $e');
          }
        }
      }
    }

    await fetchDevices();
  }

  Future<void> fetchDevices({String? labId}) async {
    try {
      final simpleResp = await supabase
          .from(devicesTable)
          .select(
            'id, name, lab_id, status, booked_by, from_time, to_time, reason, reported_by',
          )
          .order('name', ascending: true);

      if (simpleResp == null || (simpleResp is List && simpleResp.isEmpty)) {
        devices = {};
        notifyListeners();
        return;
      }

      final List<dynamic> deviceRows = List<dynamic>.from(simpleResp);

      // جلب اللابات
      final labsResp = await supabase.from(labsTable).select('id, name');
      final Map<String, String> labsMap = {};
      if (labsResp is List) {
        for (final lab in labsResp) {
          if (lab['id'] != null)
            labsMap[lab['id'].toString()] = (lab['name'] ?? '').toString();
        }
      }

      // جلب اليوزرز
      final usersResp = await supabase
          .from(usersTable)
          .select('id, name, email');
      final Map<String, Map<String, String>> usersMap = {};
      if (usersResp is List) {
        for (final user in usersResp) {
          final id = user['id'];
          if (id != null) {
            usersMap[id.toString()] = {
              'name': (user['name'] ?? '').toString(),
              'email': (user['email'] ?? '').toString(),
            };
          }
        }
      }

      // تركيب الماب النهائي مع فلترة حسب labId
      final Map<String, Map<String, dynamic>> mapped = {};
      for (final item in deviceRows) {
        final deviceLabId = item['lab_id']?.toString();

        // فلترة حسب labId لو موجود
        if (labId != null && labId != deviceLabId) continue;

        final bookedById = item['booked_by'];
        final reportedById = item['reported_by'];
        final bookedByIdStr = bookedById != null ? bookedById.toString() : null;

        String? studentName;
        String? studentEmail;

        if (bookedByIdStr != null) {
          final user = usersMap[bookedByIdStr];
          if (user != null) {
            studentName = user['name'];
            studentEmail = user['email'];
          }
        }

        mapped[item['name']] = {
          'id': item['id'],
          'name': item['name'],
          'lab_id': deviceLabId,
          'lab_name': deviceLabId != null ? labsMap[deviceLabId] : null,
          'status': item['status'] ?? 'available',
          'student': bookedByIdStr,
          'student_name': studentName,
          'student_email': studentEmail,
          'from': item['from_time']?.toString(),
          'to': item['to_time']?.toString(),
          'reason': item['reason']?.toString(),
          'reported_by': reportedById,
        };
      }

      devices = mapped;
      notifyListeners();
    } catch (e) {
      devices = {};
      notifyListeners();
    }
  }

  Future<bool> bookDeviceOnServer(
    String deviceName,
    Map<String, dynamic> bookingData,
  ) async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) return false;

      final status = devices[deviceName]?['status'] ?? 'available';
      if (status == 'not_working') return false;

      await supabase
          .from(devicesTable)
          .update({
            'status': 'booked',
            'booked_by': currentUser.id,
            'from_time': (bookingData['from'] as DateTime)
                .toUtc()
                .toIso8601String(),
            'to_time': (bookingData['to'] as DateTime)
                .toUtc()
                .toIso8601String(),
          })
          .eq('name', deviceName);

      await fetchDevices();
      return true;
    } catch (e) {
      _d('Booking error: $e');
      return false;
    }
  }

  Future<bool> reportIssueOnServer(String deviceName, String reason) async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) return false;

      await supabase
          .from(devicesTable)
          .update({'reason': reason, 'reported_by': currentUser.id})
          .eq('name', deviceName);

      await fetchDevices();
      return true;
    } catch (e) {
      _d('Report error: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
