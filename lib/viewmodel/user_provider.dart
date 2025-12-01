import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? _userEmail;
  String? get userEmail => _userEmail;

  String? _userName;
  String? get userName => _userName;

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

      // optional delay
      await Future.delayed(const Duration(milliseconds: 200));

      final current = _supabase.auth.currentUser;
      debugPrint('After signIn — auth.currentUser = $current');

      // fetch profile from Users table
      final profile = await _supabase
          .from('Users')
          .select()
          .eq('id', res.user!.id)
          .maybeSingle();

      _userName = profile?['name'] as String?;
      notifyListeners();
      return true;
    } catch (e, st) {
      debugPrint('Login exception: $e\n$st');
      return false;
    }
  }

  Future<bool> signUp(String name, String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      debugPrint('Email or password empty');
      return false;
    }

    try {
      debugPrint('Signing up: email=$email, name=$name');

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
        notifyListeners();
        return true;
      } else {
        debugPrint(
          'Signed up but no user returned. Check email confirm settings.',
        );
        return false;
      }
    } catch (e, st) {
      debugPrint('SignUp exception: $e\n$st');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('Supabase signOut error: $e');
    }

    _userEmail = null;
    _userName = null;
    _password = null;
    notifyListeners();
  }
}
