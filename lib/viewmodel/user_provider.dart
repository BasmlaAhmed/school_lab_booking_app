import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? _userEmail;
  String? get userEmail => _userEmail;

  String? _userName;
  String? get userName => _userName;

  String? _role;
  String? get role => _role;

  String? _password;

  void setEmail(String email) {
    _userEmail = email.trim();
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  Future<bool> login() async {
    if (_userEmail == null || _password == null) return false;

    try {
      final res = await _supabase.auth.signInWithPassword(
        email: _userEmail!,
        password: _password!,
      );

      if (res.user == null) {
        debugPrint('Login failed: $res');
        return false;
      }

      final profile = await _supabase
          .from('Users')
          .select()
          .eq('id', res.user!.id)
          .maybeSingle();

      if (profile != null) {
        _userName = profile['name'];
        _role = profile['role'];
        notifyListeners();
      }

      return true;
    } catch (e, st) {
      debugPrint('Login exception: $e\n$st');
      return false;
    }
  }

  Future<bool> signUp(String name, String email, String password) async {
    try {
      final res = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
      );

      if (res.user != null) {
        await _supabase.from('Users').insert({
          'id': res.user!.id,
          'name': name,
          'email': email.trim(),
          'role': 'student',
          'created_at': DateTime.now().toIso8601String(),
        });

        _userEmail = email.trim();
        _userName = name;
        _role = 'student';
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('SignUp exception: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();

    _userEmail = null;
    _userName = null;
    _role = null;
    _password = null;
    notifyListeners();
  }
}
