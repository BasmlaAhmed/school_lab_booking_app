import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/user_provider.dart';
import '../../util/app_color.dart';
import 'filter_screen.dart';
import 'sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // controllers عشان القيم تفضل موجودة
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  bool showPassword = false;

 @override
void initState() {
  super.initState();

  emailController.text;
  passController.text;

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
      backgroundColor: AppColor.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome Back",
              style: TextStyle(
                color: AppColor.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 35.sp,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              "Login to your account",
              style: TextStyle(
                color: AppColor.textPrimary.withOpacity(0.7),
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
                if (success) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const FilterScreen()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Login failed. Please try again."),
                      backgroundColor: Colors.redAccent,
                    ),
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
                    color: AppColor.textPrimary,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(width: 5),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
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
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon, color: AppColor.primaryDark),
        labelText: label,
        suffixIcon:
            isPassword
                ? IconButton(
                  onPressed: onTogglePassword,
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                )
                : null,
        labelStyle: TextStyle(color: AppColor.primaryDark),
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
