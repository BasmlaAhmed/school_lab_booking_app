import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../util/app_color.dart';

class EngineerScreen1 extends StatefulWidget {
  const EngineerScreen1({super.key});

  @override
  State<EngineerScreen1> createState() => _EngineerScreen1State();
}

class _EngineerScreen1State extends State<EngineerScreen1> {
  bool al = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: InkWell(
              onTap: () {
                print("This is the card");
                setState(() {
                  al = !al;
                });
              },
              child: AnimatedAlign(
                duration: Duration(seconds: 2),
                alignment: al ? Alignment.centerLeft : Alignment.centerRight,
                child: Card(
                  color: AppColor.primaryDark,
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Card",
                      style: TextStyle(fontSize: 40.sp, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
