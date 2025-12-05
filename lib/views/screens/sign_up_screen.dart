import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/user_provider.dart';
import '../../util/app_color.dart';
import 'labs_list_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String name = "";
  String email = "";
  String password = "";

  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Create Account",
              style: TextStyle(
                color: isDark ? Colors.white : AppColor.primaryDark,
                fontWeight: FontWeight.bold,
                fontSize: 35.sp,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              "Sign up to continue",
              style: TextStyle(
                color: isDark
                    ? Colors.white70
                    : AppColor.textPrimary.withOpacity(0.7),
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 40.h),

            /// FULL NAME
            buildField(
              label: "Full Name",
              icon: Icons.person,
              onChanged: (v) => name = v,
            ),

            SizedBox(height: 18.h),

            /// EMAIL
            buildField(
              label: "Email Address",
              icon: Icons.email,
              onChanged: (v) => email = v,
            ),

            SizedBox(height: 18.h),

            /// PASSWORD
            buildField(
              label: "Password",
              icon: Icons.lock,
              isPassword: true,
              obscureText: !showPassword,
              onTogglePassword: () {
                setState(() {
                  showPassword = !showPassword;
                });
              },
              onChanged: (v) => password = v,
            ),

            SizedBox(height: 35.h),

            /// SIGN UP BUTTON
            InkWell(
             onTap: () async {
  bool success = await userProvider.signUp(
    name,
    email,
    password,
  );

  if (!success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Sign up failed. Please try again."),
        backgroundColor: Colors.redAccent,
      ),
    );
    return;
  }

  // تحميل بيانات البروفايل
  await userProvider.loadUserProfile();

  // التوجيه حسب الدور
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const LabsListScreen()),
  );
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
                    "Sign Up",
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
                  "Already have an account?",
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 14.sp,
                  ),
                ),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    "Login",
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

  /// Reusable TextField
  Widget buildField({
    required String label,
    required IconData icon,
    required Function(String) onChanged,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      obscureText: obscureText,
      onChanged: onChanged,

      style: TextStyle(
        color: isDark ? Colors.white : Colors.black,
      ),

      decoration: InputDecoration(
        filled: true,
        fillColor: isDark ? Colors.grey.shade900 : Colors.white,

        prefixIcon: Icon(icon, color: AppColor.primaryDark),

        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.white70 : AppColor.primaryDark,
        ),

        suffixIcon: isPassword
            ? IconButton(
                onPressed: onTogglePassword,
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              )
            : null,

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(color: AppColor.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(
            color: AppColor.primarylight,
            width: 2,
          ),
        ),
      ),
    );
  }
}
