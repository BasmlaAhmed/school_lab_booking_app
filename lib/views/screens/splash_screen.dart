import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

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

    // Optional: set status bar icons to match background (safe default)
    // This will adapt automatically after build when theme changes.
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    _textAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    // 🔥 بعد 3 ثواني → نعمل Redirect حسب Session
    Timer(const Duration(seconds: 3), () async {
      // use read instead of watch; safe inside timer
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
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder:
            (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
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
    // theme-aware colors
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // choose text color that contrasts background
    final titleColor =isDark? AppColor.primarylight: AppColor.primaryDark; // LabGo main color
    final subtitleColor = cs.onBackground.withOpacity(0.85);
    final bgColor = theme.scaffoldBackgroundColor; // respect app theme

    // ensure status bar icons contrast current background
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔥 Lottie Animation (if Lottie uses colors inside asset, make sure asset supports dark)
            SizedBox(
              height: 220.h,
              child: Lottie.asset(
                "assets/splash.json",
                fit: BoxFit.contain,
                width: 400.w,
                // If your Lottie has color layers you want to tint, you can use delegates,
                // but that's optional and depends on the asset.
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
                    child: Opacity(opacity: _textAnim.value, child: child),
                  ),
                );
              },
              child: Text(
                "LabGo",
                style: TextStyle(
                  fontSize: 45.sp,
                  color: titleColor,
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
                  color: subtitleColor,
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
