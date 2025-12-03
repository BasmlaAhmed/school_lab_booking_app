import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SupabaseService {
  /// --------------------------------------
  /// GET ALL LABS
  /// --------------------------------------
  Future<List<Map<String, dynamic>>> getAllLabs() async {
    final res = await supabase
        .from("Labs")
        .select("id, name")
        .order("name", ascending: true);

    return List<Map<String, dynamic>>.from(res);
  }

  /// --------------------------------------
  /// GET DEVICES FOR A LAB (JOIN)
  /// --------------------------------------
  Future<List<Map<String, dynamic>>> getDevicesForLab(String labId) async {
    final res = await supabase
        .from("Devices")
        .select("id, name, status")
        .eq("lab_id", labId)
        .order("name", ascending: true);

    return List<Map<String, dynamic>>.from(res);
  }

  /// --------------------------------------
  /// UPDATE DEVICE STATUS
  /// --------------------------------------
  Future<void> updateDeviceStatus(String deviceId, String status) async {
    await supabase
        .from("Devices")
        .update({"status": status})
        .eq("id", deviceId);
  }
}
