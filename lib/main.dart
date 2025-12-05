import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart'as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'viewmodel/device_provider.dart';
import 'viewmodel/lab_provider.dart';
import 'viewmodel/theme_provider.dart';
import 'viewmodel/user_provider.dart';
import 'views/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://osecssqonzfrnweazuyk.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9zZWNzc3Fvbnpmcm53ZWF6dXlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM5MDQyODcsImV4cCI6MjA3OTQ4MDI4N30.EF-S16pJMTA34pN87ckqCZXxfRGd2J-nZLF5SX3ZtC0',
  );

  runApp(
    p.MultiProvider(
      providers: [
        p.ChangeNotifierProvider(create: (_) => UserProvider()),
        p.ChangeNotifierProvider(create: (_) => LabProvider()),
        p.ChangeNotifierProvider(create: (_) => DeviceProvider()),
        p.ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          themeMode:p.Provider.of<ThemeProvider>(context).themeMode,

          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Color(0xfff6faf9),
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.black,
          ),

          home: const SplashLabGo(),
        );
      },
    );
  }
}

