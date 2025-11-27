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
    if (_userEmail!.isEmpty || _password!.isEmpty) return false;

    try {
      // signIn (login)
      final res = await _supabase.auth.signInWithPassword(
        email: _userEmail!,
        password: _password!,
      );

      if (res.user == null) {
        // قد يكون المستخدم مسجّل لكن لم يؤكد الإيميل (session = null) أو خطأ آخر
        print('Login failed or email not confirmed. session: ${res.session}');
        return false;
      }

      // جلب بيانات المستخدم من جدول الـ users — تأكد من اسم الجدول (users أو Users)
      final userData = await _supabase
          .from('Users') // أو 'Users' إذا جدولك اسمه بكابيتال
          .select()
          .eq('email', _userEmail!)
          .maybeSingle();

      if (userData != null) {
        _userName = userData['name'] as String?;
      }

      notifyListeners();
      return true;
    } catch (e, st) {
      print('Login exception: $e\n$st');
      return false;
    }
  }

  Future<bool> signUp(String name, String email, String password) async {
    // Validate inputs early
    if (email.trim().isEmpty || password.isEmpty) {
      print('Email or password empty');
      return false;
    }

    try {
      // Print for debugging — تأكد أن القيم توصل هنا
      print('Signing up: email=$email, name=$name');

      // استدعاء الـ signUp
      final res = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
      );

      // إذا ال user موجود (يعني تم إنشاء حساب)
      if (res.user != null) {
        // insert into users table — تأكد اسم الجدول (users vs Users)
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
        // لو confirm email مفعل، user ممكن يرجع ولكن session null — تحقق من ذلك
        print('Signed up but no user returned. Check email confirm settings.');
        return false;
      }
    } catch (e, st) {
      // ممكن ترجع AuthApiException أو PostgrestException
      print('SignUp exception: $e\n$st');

      // أمثلة للتحقق السريع:
      // - لو الرسالة فيها anonymous_provider_disabled => غالبًا الإيميل/الباسوورد موصلتش (null/empty)
      // - لو الرسالة فيها PGRST205 => اسم الجدول غلط عند ال insert

      return false;
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    _userEmail = null;
    _userName = null;
    notifyListeners();
  }
}
