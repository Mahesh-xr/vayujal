// screens/devices_screen.dart
import 'package:flutter/material.dart';
import 'package:vayujal/widgets/navigations/custom_app_bar.dart';
import 'package:vayujal/widgets/device_widgets/device_card.dart';
import 'package:vayujal/widgets/device_widgets/filter_chip_widget.dart';
import 'package:vayujal/widgets/device_widgets/search_bar_widget.dart';


class DevicesScreen extends StatefulWidget {
  const DevicesScreen({Key? key}) : super(key: key);

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilterIndex = 0;
  int _currentNavIndex = 1;

  final List<String> _filterOptions = [
    'AWG Model',
    'AWG Serial Number',
  ];

  final List<Map<String, String>> _devices = [
    {
      'model': 'AWG100',
      'serialNumber': 'AWG100-2023-12345',
      'customer': 'Acme Corporation',
      'location': 'Chennai',
      'lastService': '2023-03-15',
    },
    {
      'model': 'AWG100',
      'serialNumber': 'AWG100-2023-12345',
      'customer': 'Acme Corporation',
      'location': 'Chennai',
      'lastService': '2023-03-15',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar:const CustomAppBar(title: 'Add New Device'),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildSearchAndRegisterSection(),
          const SizedBox(height: 16),
          _buildFilterSection(),
          const SizedBox(height: 8),
          Expanded(
            child: _buildDevicesList(),
          ),
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
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
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
          const Icon(
            Icons.tune,
            color: Colors.black,
            size: 20,
          ),
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
          deviceModel: device['model']!,
          serialNumber: device['serialNumber']!,
          customer: device['customer']!,
          location: device['location']!,
          lastService: device['lastService']!,
          onEdit: () {
            // Handle edit
            print('Edit device: ${device['serialNumber']}');
          },
          onService: () {
            // Handle service
            print('Service device: ${device['serialNumber']}');
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