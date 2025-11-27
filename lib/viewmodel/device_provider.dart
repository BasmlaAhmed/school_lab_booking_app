import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class DeviceProvider with ChangeNotifier {
  Map<String, Map<String, dynamic>> devices = {};

  // Fake data مؤقتاً قبل الربط بالسوبابيز
  Map<String, Map<String, dynamic>> fakeDevices = {
    "PC 1": {
      "status": "available",
      "student": null,
      "from": null,
      "to": null,
      "date": null
    },
    "PC 2": {
      "status": "booked",
      "student": "Ahmed",
      "from": "14:00",
      "to": "15:00",
      "date": "20/11/2025"
    },
    "PC 3": {"status": "not_working", "reason": "No Display"},
    "PC 4": {"status": "available"},
  };

  DeviceProvider() {
    // مؤقتاً نستخدم البيانات الوهمية
    devices = Map.from(fakeDevices);
  }

  /// جلب الأجهزة من Supabase (الإصدار الجديد بدون .execute())
  Future<void> fetchDevices() async {
    try {
      // select() بترجع List مباشرة في الإصدارات الحديثة
      final List<dynamic> response = await supabase.from('devices').select();

      // لو مفيش بيانات، نفضّل نرجع الخريطة الفاضية أو البيانات الوهمية
      if (response.isEmpty) {
        devices = {};
        notifyListeners();
        return;
      }

      // تحويل الـ List الناتجة إلى Map<String, Map<String, dynamic>>
      final Map<String, Map<String, dynamic>> mapped = {};
      for (final item in response) {
        if (item == null) continue;
        // تأكد من الـ type ووجود الاسم
        final name = (item['name'] ?? '').toString();
        if (name.isEmpty) continue;

        mapped[name] = {
          'status': item['status'],
          if (item['booked_by'] != null) 'student': item['booked_by'],
          if (item['from'] != null) 'from': item['from'],
          if (item['to'] != null) 'to': item['to'],
          if (item['date'] != null) 'date': item['date'],
          if (item['reason'] != null) 'reason': item['reason'],
        };
      }

      devices = mapped;
      notifyListeners();
    } catch (e) {
      print('Error fetching devices: $e');
    }
  }

  /// حجز جهاز محلياً (بدون اتصال بالسوبابيز) — لو عايز تخزن على السوبابيز، ممكن أضيف update/insert
  void bookDevice(String deviceName, Map<String, dynamic> bookingData) {
    if (devices.containsKey(deviceName)) {
      devices[deviceName]!.addAll(bookingData);
      devices[deviceName]!['status'] = 'booked';
      notifyListeners();
    }
  }

  /// إلغاء الحجز محلياً
  void releaseDevice(String deviceName) {
    if (devices.containsKey(deviceName)) {
      devices[deviceName]!['status'] = 'available';
      devices[deviceName]!.remove('student');
      devices[deviceName]!.remove('from');
      devices[deviceName]!.remove('to');
      devices[deviceName]!.remove('date');
      notifyListeners();
    }
  }

  /// اقتراح: دوال تزامن مع Supabase (update / insert) لو حابّة تخلي الحجز persistent
  Future<void> bookDeviceOnServer(String deviceName, Map<String, dynamic> bookingData) async {
    try {
      await supabase
          .from('devices')
          .update({
            'status': 'booked',
            'booked_by': bookingData['student'],
            'from': bookingData['from'],
            'to': bookingData['to'],
            'date': bookingData['date'],
          })
          .eq('name', deviceName);
      // بعد التحديث على السيرفر نعمل fetch محلي لتحديث ال state
      await fetchDevices();
    } catch (e) {
      print('Error booking device on server: $e');
    }
  }

  Future<void> releaseDeviceOnServer(String deviceName) async {
    try {
      await supabase.from('devices').update({
        'status': 'available',
        'booked_by': null,
        'from': null,
        'to': null,
        'date': null,
      }).eq('name', deviceName);
      await fetchDevices();
    } catch (e) {
      print('Error releasing device on server: $e');
    }
  }
}
