import 'package:flutter/material.dart';
import '../widgets/navigations/custom_app_bar.dart';
import '../widgets/add_new_device_widgets/device_form.dart';
import '../widgets/navigations/bottom_navigation.dart';

// ...


class AddDeviceScreen extends StatefulWidget {
  // Changed to StatefulWidget
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  int _currentIndex = 0; // Added state for current index

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[80],
      appBar: const CustomAppBar(title: 'Add New Device'),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: DeviceForm(),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, '/home');
                break;
              case 1:
                Navigator.pushReplacementNamed(context, '/alldevice');
              case 2:
                Navigator.pushReplacementNamed(context, '/profile');
                break;
              case 3:
                Navigator.pushReplacementNamed(context, '/history');
                break;
              case 4:
                Navigator.pushReplacementNamed(context, '/notifications');
                break;
            }
          
        },
      ),
    );
  }
}
