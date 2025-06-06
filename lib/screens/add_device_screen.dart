import 'package:flutter/material.dart';
import '../widgets/navigations/custom_app_bar.dart';
import '../widgets/add_new_device_widgets/device_form.dart';



class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
   // Added state for current index

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[80],
      appBar: const CustomAppBar(title: 'Add New Device'),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: DeviceForm(),
      ),
      
    );
  }
}
