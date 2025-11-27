import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/lab_model.dart';

class LabProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<LabModel> _labs = [];
  List<LabModel> get labs => _labs;

  /// ------------------------------------------------
  ///   Fetch Labs + JOIN Users to show engineer name
  /// ------------------------------------------------
  Future<void> fetchLabs() async {
    try {
      final response = await _supabase
          .from('Labs')
          .select('''
            id,
            name,
            status,
            from_time,
            to_time,
            class_name,
            booked_by,
            users:booked_by (
              name
            )
          ''')
          .order('name', ascending: true);

      if (response == null) return;

      final List data = response as List;

      _labs = data.map<LabModel>((lab) {
        // user info returned under alias "users"
        final userData = lab['users'];
        final engineerName = (userData != null && userData is Map && userData['name'] != null)
            ? userData['name'].toString()
            : null;

        return LabModel(
          id: lab['id']?.toString() ?? '',
          name: lab['name']?.toString() ?? '',
          status: lab['status']?.toString() ?? '',
          bookedBy: engineerName,
          fromTime: lab['from_time']?.toString(),
          toTime: lab['to_time']?.toString(),
          className: lab['class_name']?.toString(),
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      // print for debugging
      debugPrint('fetchLabs error: $e');
    }
  }

  /// --------------------------
  ///   Fetch a single lab
  /// --------------------------
  Future<Map<String, dynamic>?> getLab(String labId) async {
    try {
      final lab = await _supabase.from('Labs').select().eq('id', labId).maybeSingle();
      if (lab == null) return null;
      return Map<String, dynamic>.from(lab);
    } catch (e) {
      debugPrint('Exception fetching single lab: $e');
      return null;
    }
  }

  /// --------------------------
  ///   Add New Lab
  /// --------------------------
  Future<bool> addLab({
    required String id,
    required String name,
    String className = "",
  }) async {
    try {
      await _supabase.from('Labs').insert({
        'id': id,
        'name': name,
        'status': 'available',
        'class_name': className,
        'created_at': DateTime.now().toIso8601String(),
      });

      await fetchLabs();
      return true;
    } catch (e) {
      debugPrint('Exception adding lab: $e');
      return false;
    }
  }

  /// --------------------------
  ///   Book Lab
  ///  (signature changed to match how LabInfo calls it)
  /// --------------------------
  Future<bool> bookLab(
    String labId,
    String className,
    String fromTimeString,
    String toTimeString,
  ) async {
    try {
      final lab = await getLab(labId);

      if (lab == null) {
        debugPrint("Lab not found");
        return false;
      }

      if ((lab['status'] ?? '').toString() == 'booked') {
        debugPrint("Lab already booked");
        return false;
      }

      final currentUser = _supabase.auth.currentUser;
      final currentUserId = currentUser != null ? currentUser.id : null;

      await _supabase.from('Labs').update({
        'status': 'booked',
        'booked_by': currentUserId,
        'class_name': className,
        'from_time': fromTimeString,
        'to_time': toTimeString,
      }).eq('id', labId);

      await fetchLabs();
      return true;
    } catch (e) {
      debugPrint('Exception booking lab: $e');
      return false;
    }
  }

  /// --------------------------
  ///   Release Lab
  /// --------------------------
  Future<bool> releaseLab(String labId) async {
    try {
      final lab = await getLab(labId);

      if (lab == null) {
        debugPrint("Lab not found");
        return false;
      }

      if ((lab['status'] ?? '').toString() == 'available') {
        debugPrint("Lab already available");
        return false;
      }

      await _supabase.from('Labs').update({
        'status': 'available',
        'booked_by': null,
        'from_time': null,
        'to_time': null,
      }).eq('id', labId);

      await fetchLabs();
      return true;
    } catch (e) {
      debugPrint('Exception releasing lab: $e');
      return false;
    }
  }
    /// --------------------------
  ///   Release expired bookings
  /// --------------------------
  Future<void> releaseExpired() async {
    try {
      final nowIso = DateTime.now().toUtc().toIso8601String();

      final res = await _supabase
          .from('Labs')
          .select('id, to_time')
          .eq('status', 'booked')
          .lte('to_time', nowIso);

      if (res == null) return;

      final rows = res as List<dynamic>? ?? [];
      for (final row in rows) {
        final id = row['id']?.toString();
        if (id == null || id.isEmpty) continue;
        await releaseLab(id);
      }
    } catch (e) {
      debugPrint('releaseExpired error: $e');
    }
  }

}