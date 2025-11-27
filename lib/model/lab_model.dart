class LabModel {
  final String id;
  final String name;
  final String status;
  final String? bookedBy;
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
      String cleaned = iso.toString().trim();

      // إذا كان الوقت فقط بدون تاريخ 14:00 أو 14:00:00
      if (RegExp(r'^\d{2}:\d{2}').hasMatch(cleaned)) {
        cleaned = "2025-01-01T$cleaned";
      }

      // لو الشكل فيه مسافة بدل T
      if (cleaned.contains(" ") && !cleaned.contains("T")) {
        cleaned = cleaned.replaceFirst(" ", "T");
      }

      // Parse time
      final dt = DateTime.parse(cleaned);

      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? "PM" : "AM";

      return "$hour:$minute $ampm";
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
