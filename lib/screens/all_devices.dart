import 'package:flutter/material.dart';
import 'package:vayujal/widgets/add_new_device_widgets/device_form.dart';
import 'package:vayujal/widgets/navigations/bottom_navigation.dart';
import 'package:vayujal/widgets/navigations/custom_app_bar.dart';
import 'package:vayujal/widgets/device_widgets/device_card.dart';
import 'package:vayujal/widgets/device_widgets/filter_chip_widget.dart';
import 'package:vayujal/widgets/device_widgets/search_bar_widget.dart';
import 'package:vayujal/DatabaseACtion/AdminAction.dart';

class DevicesScreen extends StatefulWidget {
  final Map<String, dynamic>? newDevice;

  const DevicesScreen({super.key, this.newDevice});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilterIndex = 0;

  final List<String> _filterOptions = ['AWG Model', 'AWG Serial Number'];

  List<Map<String, dynamic>> _devices = [];

  @override
  void initState() {
    super.initState();
    fetchDevices();
  }

  Future<void> fetchDevices() async {
    try {
      final fetchedDevices = await AdminAction.getAllDevices();

      if (widget.newDevice != null) {
        fetchedDevices.insert(0, widget.newDevice!);
      }

      setState(() {
        _devices = fetchedDevices;
      });
    } catch (e) {
      print('Error fetching devices: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[80],
      appBar: const CustomAppBar(title: 'All Devices'),
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
      bottomNavigationBar: BottomNavigation(
                        currentIndex: 1,
                        onTap: (index) {
                          switch (index) {
                            case 0:
                              Navigator.pushReplacementNamed(context, '/home');
                              break;
                            case 1:
                              Navigator.pushReplacementNamed(
                                context,
                                '/alldevice',
                              );
                            case 2:
                              Navigator.pushReplacementNamed(
                                context,
                                '/profile',
                              );
                              break;
                            case 3:
                              Navigator.pushReplacementNamed(
                                context,
                                '/history',
                              );
                              break;
                            case 4:
                              Navigator.pushReplacementNamed(
                                context,
                                '/notifications',
                              );
                              break;
                          }
                        },
                      ),
    
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
                // TODO: Implement search logic
              },
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DeviceForm()),
              );
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
    if (_devices.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _devices.length,
      itemBuilder: (context, index) {
        final device = _devices[index];
        final deviceInfo = device['deviceInfo'] ?? {};
        final customerDetails = device['customerDetails'] ?? {};
        final locationDetails = device['locationDetails'] ?? {};

        return DeviceCard(
          deviceModel: deviceInfo['model'] ?? 'Unknown',
          serialNumber: deviceInfo['serialNumber'] ?? 'N/A',
          customer: customerDetails['company'] ?? 'Unknown',
          location: locationDetails['city'] ?? 'Unknown',
          lastService: deviceInfo['installationDate'] ?? 'N/A',
          onEdit: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => Scaffold(
                      appBar: const CustomAppBar(title: 'Edit Device Details'),
                      body: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: DeviceForm(deviceToEdit: device),
                      ),
                      bottomNavigationBar: BottomNavigation(
                        currentIndex: 0,
                        onTap: (index) {
                          switch (index) {
                            case 0:
                              Navigator.pushReplacementNamed(context, '/home');
                              break;
                            case 1:
                              Navigator.pushReplacementNamed(
                                context,
                                '/alldevice',
                              );
                            case 2:
                              Navigator.pushReplacementNamed(
                                context,
                                '/profile',
                              );
                              break;
                            case 3:
                              Navigator.pushReplacementNamed(
                                context,
                                '/history',
                              );
                              break;
                            case 4:
                              Navigator.pushReplacementNamed(
                                context,
                                '/notifications',
                              );
                              break;
                          }
                        },
                      ),
                    ),
              ),
            );
          },
          onService: () {
            print('Service device: ${deviceInfo['serialNumber']}');
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
