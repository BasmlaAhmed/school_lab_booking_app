class DeviceModel {
  final String id;
  final String name;
  final String status;
  final String labId;
  final String? bookedBy;
  final String? fromTime;
  final String? toTime;

  DeviceModel({
    required this.id,
    required this.name,
    required this.status,
    required this.labId,
    this.bookedBy,
    this.fromTime,
    this.toTime,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'].toString(),
      name: json['name'],
      status: json['status'],
      labId: json['lab_id'],
      bookedBy: json['booked_by'],
      fromTime: json['from_time'],
      toTime: json['to_time'],
    );
  }
}
