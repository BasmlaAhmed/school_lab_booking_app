import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/user_provider.dart';
import '../../util/app_color.dart';

// الشاشات اللي هتتنقلي ليها حسب الدور
import 'engineer_screen.dart';
import 'filter_screen.dart';
import 'labs_list_screen.dart';
import 'sign_up_screen.dart';
import 'super_admin_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  bool showPassword = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.setEmail(emailController.text);
      userProvider.setPassword(passController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome Back",
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : AppColor.primaryDark,
                fontWeight: FontWeight.bold,
                fontSize: 35.sp,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              "Login to your account",
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColor.textsecondary.withOpacity(0.7)
                    : AppColor.textPrimary.withOpacity(0.7),
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 40.h),

            /// EMAIL
            buildField(
              label: "Email Address",
              icon: Icons.email,
              controller: emailController,
              onChanged: (value) => userProvider.setEmail(value),
            ),

            SizedBox(height: 18.h),

            /// PASSWORD
            buildField(
              label: "Password",
              icon: Icons.lock,
              controller: passController,
              isPassword: true,
              obscureText: !showPassword,
              onChanged: (value) => userProvider.setPassword(value),
              onTogglePassword: () {
                setState(() => showPassword = !showPassword);
              },
            ),

            SizedBox(height: 35.h),

            /// LOGIN BUTTON
            InkWell(
              onTap: () async {
  bool success = await userProvider.login();

  if (!success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Login failed. Please try again."),
        backgroundColor: Colors.redAccent,
      ),
    );
    return;
  }

  // مهم جدًا — تحميل بيانات المستخدم
  await userProvider.loadUserProfile();

  // التوجيه حسب الدور
  switch (userProvider.role) {
    case "super_admin":
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SuperAdminLabsScreen()),
      );
      break;

    case "engineer":
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const EngineerScreen()),
      );
      break;

    case "student":
    default:
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LabsListScreen()),
      );
  }
},

              child: Container(
                width: double.infinity,
                height: 55.h,
                decoration: BoxDecoration(
                  color: AppColor.primaryDark,
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Center(
                  child: Text(
                    "Login",
                    style: TextStyle(
                      color: AppColor.textsecondary,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account?",
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    fontSize: 14.sp,
                  ),
                ),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "Sign Up",
                    style: TextStyle(
                      color: AppColor.primaryDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Reusable field
  Widget buildField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required Function(String) onChanged,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      onChanged: onChanged,
      style: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade900
            : Colors.white,
        prefixIcon: Icon(icon, color: AppColor.primaryDark),
        labelText: label,
        suffixIcon: isPassword
            ? IconButton(
                onPressed: onTogglePassword,
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                ),
              )
            : null,
        labelStyle: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white70
              : AppColor.primaryDark,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(color: AppColor.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(color: AppColor.primarylight, width: 2),
        ),
      ),
    );
  }
}
