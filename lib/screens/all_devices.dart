// screens/devices_screen.dart
import 'package:flutter/material.dart';
import 'package:vayujal/widgets/add_new_device_widgets/device_form.dart';
import 'package:vayujal/widgets/navigations/custom_app_bar.dart';
import 'package:vayujal/widgets/device_widgets/device_card.dart';
import 'package:vayujal/widgets/device_widgets/filter_chip_widget.dart';
import 'package:vayujal/widgets/device_widgets/search_bar_widget.dart';

class DevicesScreen extends StatefulWidget {
  final Map<String, dynamic>? newDevice;

  const DevicesScreen({Key? key, this.newDevice}) : super(key: key);

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilterIndex = 0;
  int _currentNavIndex = 1;

  final List<String> _filterOptions = ['AWG Model', 'AWG Serial Number'];

final List<Map<String, dynamic>> _devices = [
  {
    'deviceInfo': {
      'model': 'Model A',
      'serialNumber': '431313',
      'dispenserDetails': 'Type A',
      'powerSource': 'AC Power',
      'installationDate': '19-05-2025',
      'uploadedPhotos': [],
    },
    'customerDetails': {
      'name': '',
      'company': 'kjkj',
      'phone': '341634510',
      'email': 'mahesh@gmail.com',
    },
    'locationDetails': {
      'city': 'lskdf;skd;f',
      'state': 'asdfkjbskdafb',
      'fullAddress': 'sdfsdf',
    },
    'maintenanceContract': {
      'annualContract': true,
    },
  },
  {
    'deviceInfo': {
      'model': 'Model B',
      'serialNumber': '987654',
      'dispenserDetails': 'Type B',
      'powerSource': 'Battery',
      'installationDate': '01-04-2024',
      'uploadedPhotos': [],
    },
    'customerDetails': {
      'name': 'John Doe',
      'company': 'Zeta Tech',
      'phone': '9876543210',
      'email': 'john.doe@zetatech.com',
    },
    'locationDetails': {
      'city': 'Mumbai',
      'state': 'Maharashtra',
      'fullAddress': '123 Zeta Street, Tech Park',
    },
    'maintenanceContract': {
      'annualContract': false,
    },
  },
];


  @override
  void initState() {
    super.initState();
    if (widget.newDevice != null) {
      _devices.insert(0, widget.newDevice!); // Add to top of the list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const CustomAppBar(title: 'Add New Device'),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildSearchAndRegisterSection(),
          const SizedBox(height: 16),
          _buildFilterSection(),
          const SizedBox(height: 8),
          Expanded(child: _buildDevicesList()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Devices',
        style: TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Image.asset(
            'assets/images/vayujal_logo.png', // You'll need to add this logo
            height: 40,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndRegisterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: SearchBarWidget(
              controller: _searchController,
              onChanged: (value) {
                // Handle search
              },
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              // Handle register device
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Register\nDevice',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.tune, color: Colors.black, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filterOptions.length,
              itemBuilder: (context, index) {
                return FilterChipWidget(
                  label: _filterOptions[index],
                  isSelected: _selectedFilterIndex == index,
                  icon: Icons.check_box_outline_blank,
                  onTap: () {
                    setState(() {
                      _selectedFilterIndex = index;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _devices.length,
      itemBuilder: (context, index) {
        final device = _devices[index];
        return DeviceCard(
  deviceModel: device['deviceInfo']['model'],
  serialNumber: device['deviceInfo']['serialNumber'],
  customer: device['customerDetails']['company'],
  location: device['locationDetails']['city'],
  lastService: device['deviceInfo']['installationDate'],
  onEdit: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceForm(deviceToEdit: device),
      ),
    );
  },
  onService: () {
    // Handle service
    print('Service device: ${device['deviceInfo']['serialNumber']}');
  },
);

      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
