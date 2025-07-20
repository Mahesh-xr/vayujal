



import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vayujal/firebase_options.dart';
import 'package:vayujal/screens/all_devices.dart';
import 'package:vayujal/screens/all_service_request_page.dart';
import 'package:vayujal/screens/dashboard_screen.dart';
import 'package:vayujal/screens/login_screen.dart';
import 'package:vayujal/screens/service_personel_screen.dart';
import 'utils/constants.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized(); // ✅ Required to initialize Flutter engine
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );

   
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Technician App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: AppConstants.primaryColor,
        scaffoldBackgroundColor: AppConstants.backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppConstants.textPrimaryColor,
          elevation: 0,
          centerTitle: false,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: AppConstants.buttonBorderRadius,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color.fromARGB(255, 21, 83, 134), width: 2),
          ),
        ),
      ),
      home: const LoginScreen(),
       routes: {
    '/home': (context) => const LoginScreen(),
    '/alldevice': (context) => const DevicesScreen(),
    '/profile': (context) =>  ServicePersonnelPage(),
    '/history': (context) => const AllServiceRequestsPage(),
    // '/notifications': (context) => const NotificationScreen(),
    '/login':(context) => const LoginScreen(),
    '/dashboard':(context) => const DashboardScreen()
  }
    );
  }
}
