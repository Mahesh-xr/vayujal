import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vayujal/firebase_options.dart';
import 'package:vayujal/screens/all_devices.dart';
import 'screens/add_device_screen.dart';


void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Device Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AddDeviceScreen(),
       routes: {
        '/alldevice': (context) => const DevicesScreen(),
        
      },
      debugShowCheckedModeBanner: false,
    );
  }
}