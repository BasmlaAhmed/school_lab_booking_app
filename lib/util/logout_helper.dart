import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/user_provider.dart';
import '../util/app_color.dart';
import '../views/screens/login_screen.dart';

Future<void> showLogoutDialog(
  BuildContext context, {
  required bool isDark,
}) async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: isDark ? Colors.black : Colors.white,
      title: Text(
        "Confirm Log Out",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : AppColor.textPrimary,
        ),
      ),
      content: Text(
        "Are you sure you want to log out?",
        style: TextStyle(
          fontSize: 16,
          color: isDark ? Colors.white70 : AppColor.textPrimary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Cancel",
            style: TextStyle(
              color: isDark ? Colors.white : AppColor.primaryDark,
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context); // يقفل الديالوج

            // 1- Logout من Supabase + تصفير البيانات
            await userProvider.logout();

            // 2- رجوع لشاشة اللوجين مع مسح ال stack كله
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
          child: const Text("Log Out", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
