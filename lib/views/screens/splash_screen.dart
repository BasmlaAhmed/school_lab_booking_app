import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../util/app_color.dart';
import '../../viewmodel/user_provider.dart';

// الشاشات
import 'engineer_screen.dart';
import 'get_started.dart';
import 'labs_list_screen.dart';
import 'super_admin_screen.dart';

class SplashLabGo extends StatefulWidget {
  const SplashLabGo({super.key});

  @override
  State<SplashLabGo> createState() => _SplashLabGoState();
}

class _SplashLabGoState extends State<SplashLabGo>
    with TickerProviderStateMixin {

  late AnimationController _textAnim;

  @override
  void initState() {
    super.initState();

    _textAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    // 🔥 بعد 3 ثواني → نعمل Redirect حسب Session
    Timer(const Duration(seconds: 3), () async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // لو مفيش session → أول مرة يفتح الأب
      if (!userProvider.isLoggedIn) {
        _goTo(const GetStarted());
        return;
      }

      // لو فيه session → نقرأ بيانات المستخدم
      await userProvider.loadUserProfile();

      switch (userProvider.role) {
        case "student":
          _goTo(const LabsListScreen());
          break;

        case "engineer":
          _goTo(const EngineerScreen());
          break;

        case "super_admin":
          _goTo(const SuperAdminLabsScreen());
          break;

        default:
          _goTo(const GetStarted());
      }
    });
  }

  void _goTo(Widget screen) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _textAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // 🔥 Lottie Animation
            Center(
              child: SizedBox(
                height: 220.h,
                child: Lottie.asset(
                  "assets/splash.json",
                  fit: BoxFit.contain,
                  width: 400.w,
                ),
              ),
            ),

            // ✨ LabGo Title Animation
            AnimatedBuilder(
              animation: _textAnim,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - _textAnim.value)),
                  child: Transform.scale(
                    scale: 0.8 + (_textAnim.value * 0.2),
                    child: Opacity(
                      opacity: _textAnim.value,
                      child: child,
                    ),
                  ),
                );
              },
              child: Text(
                "LabGo",
                style: TextStyle(
                  fontSize: 45.sp,
                  color: AppColor.primaryDark,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            SizedBox(height: 8.h),

            FadeTransition(
              opacity: _textAnim,
              child: Text(
                "Manage • Reserve • Control",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColor.primaryDark,
                  fontSize: 15.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
