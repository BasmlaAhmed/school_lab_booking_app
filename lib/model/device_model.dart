class DeviceModel {
  final String id;
  final String name;
  final String status;
  final String? bookedBy;
  final String? fromTime;
  final String? toTime;
  final String? date;
  final String? reason;

  DeviceModel({
    required this.id,
    required this.name,
    required this.status,
    this.bookedBy,
    this.fromTime,
    this.toTime,
    this.date,
    this.reason,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'].toString(),
      name: json['name'],
      status: json['status'],
      bookedBy: json['booked_by'],
      fromTime: json['from_time'],
      toTime: json['to_time'],
      date: json['date'],
      reason: json['reason'],
    );
  }
}
