import 'package:intl/intl.dart';

class LabModel {
  final String id;
  final String name; // lab name
  final String status;
  final String? bookedBy; // user name
  final String? className;
  final String? fromTime;
  final String? toTime;

  LabModel({
    required this.id,
    required this.name,
    required this.status,
    this.bookedBy,
    this.className,
    this.fromTime,
    this.toTime,
  });

  /// 🔥 دالة لتحويل ISO → وقت مقروء
  static String? formatTime(String? iso) {
    if (iso == null) return null;

    try {
      final dt = DateTime.parse(iso);

      // استخدم DateFormat عشان تظبط الشكل
      final formatted = DateFormat('dd/MM/yyyy - hh:mm a').format(dt); // لو عايزه اشيل الديت هيبقي من دي

      return formatted;
    } catch (e) {
      print("FORMAT ERROR → $iso");
      return iso; // fallback
    }
  }

  factory LabModel.fromMap(Map<String, dynamic> data) {
    return LabModel(
      id: data['id'].toString(),
      name: data['name'] ?? "",
      status: data['status'] ?? "available",

      bookedBy:
          data['Users'] != null &&
              data['Users'] is List &&
              data['Users'].isNotEmpty
          ? data['Users'][0]['name']
          : null,

      className: data['class_name'],

      /// ⬅ هنا اتظبطوا 👇
      fromTime: formatTime(data['from_time']),
      toTime: formatTime(data['to_time']),
    );
  }
}
