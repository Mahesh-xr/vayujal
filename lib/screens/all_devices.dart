import 'package:flutter/material.dart';
import 'package:vayujal/DatabaseAction/adminAction.dart';
import 'package:vayujal/screens/new_service_request_page.dart';
import 'package:vayujal/widgets/add_new_device_widgets/device_form.dart';
import 'package:vayujal/widgets/navigations/bottom_navigation.dart';
import 'package:vayujal/widgets/navigations/custom_app_bar.dart';
import 'package:vayujal/widgets/device_widgets/device_card.dart';
import 'package:vayujal/widgets/device_widgets/search_bar_widget.dart';

class DevicesScreen extends StatefulWidget {
  final Map<String, dynamic>? newDevice;

  const DevicesScreen({super.key, this.newDevice});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _devices = [];
  List<Map<String, dynamic>> _filteredDevices = [];
  
  // Filter options
  Map<String, List<String>> _selectedFilters = {
    'model': [],
    'city': [],
    'state': [],
  };
  
  // Available filter options
  final List<String> _modelOptions = ['VJ - Home', 'VJ - Plus', 'VJ - Grand', 'VJ - Ultra', 'VJ - Max'];
  List<String> _cityOptions = [];
  List<String> _stateOptions = [];

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
        _filteredDevices = List.from(_devices);
        _extractUniqueOptions();
      });
    } catch (e) {
      print('Error fetching devices: $e');
    }
  }

  void _extractUniqueOptions() {
    Set<String> cities = {};
    Set<String> states = {};
    
    for (var device in _devices) {
      final locationDetails = device['locationDetails'] ?? {};
      final city = locationDetails['city']?.toString().trim();
      final state = locationDetails['state']?.toString().trim();
      
      if (city != null && city.isNotEmpty) cities.add(city);
      if (state != null && state.isNotEmpty) states.add(state);
    }
    
    _cityOptions = cities.toList()..sort();
    _stateOptions = states.toList()..sort();
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_devices);
    
    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered.where((device) {
        final deviceInfo = device['deviceInfo'] ?? {};
        final customerDetails = device['customerDetails'] ?? {};
        final locationDetails = device['locationDetails'] ?? {};
        
        return (deviceInfo['model']?.toString().toLowerCase().contains(searchTerm) ?? false) ||
               (deviceInfo['serialNumber']?.toString().toLowerCase().contains(searchTerm) ?? false) ||
               (customerDetails['company']?.toString().toLowerCase().contains(searchTerm) ?? false) ||
               (locationDetails['city']?.toString().toLowerCase().contains(searchTerm) ?? false);
      }).toList();
    }
    
    // Apply model filter
    if (_selectedFilters['model']!.isNotEmpty) {
      filtered = filtered.where((device) {
        final model = device['deviceInfo']?['model']?.toString();
        return model != null && _selectedFilters['model']!.contains(model);
      }).toList();
    }
    
    // Apply city filter
    if (_selectedFilters['city']!.isNotEmpty) {
      filtered = filtered.where((device) {
        final city = device['locationDetails']?['city']?.toString();
        return city != null && _selectedFilters['city']!.contains(city);
      }).toList();
    }
    
    // Apply state filter
    if (_selectedFilters['state']!.isNotEmpty) {
      filtered = filtered.where((device) {
        final state = device['locationDetails']?['state']?.toString();
        return state != null && _selectedFilters['state']!.contains(state);
      }).toList();
    }
    
    setState(() {
      _filteredDevices = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[80],
      appBar: const CustomAppBar(title: 'All Devices'),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildSearchSection(),
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
              Navigator.pushReplacementNamed(context, '/alldevice');
              break;
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

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SearchBarWidget(
        controller: _searchController,
        onChanged: (value) {
          _applyFilters();
        },
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune, color: Colors.black, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Filters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              if (_hasActiveFilters())
                TextButton(
                  onPressed: _clearAllFilters,
                  child: const Text('Clear All'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildFilterDropdown('AWG Model', 'model', _modelOptions)),
              const SizedBox(width: 8),
              Expanded(child: _buildFilterDropdown('City', 'city', _cityOptions)),
              const SizedBox(width: 8),
              Expanded(child: _buildFilterDropdown('State', 'state', _stateOptions)),
            ],
          ),
          if (_hasActiveFilters()) ...[
            const SizedBox(height: 8),
            _buildActiveFiltersDisplay(),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String title, String filterKey, List<String> options) {
    if (options.isEmpty) return const SizedBox.shrink();
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: PopupMenuButton<String>(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: _selectedFilters[filterKey]!.isNotEmpty 
                        ? Colors.blue 
                        : Colors.grey[700],
                    fontWeight: _selectedFilters[filterKey]!.isNotEmpty 
                        ? FontWeight.w600 
                        : FontWeight.normal,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: _selectedFilters[filterKey]!.isNotEmpty 
                    ? Colors.blue 
                    : Colors.grey[700],
                size: 20,
              ),
            ],
          ),
        ),
        itemBuilder: (context) => options.map((option) {
          final isSelected = _selectedFilters[filterKey]!.contains(option);
          return PopupMenuItem<String>(
            value: option,
            child: StatefulBuilder(
              builder: (context, setMenuState) => Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (bool? value) {
                      setMenuState(() {
                        if (value == true) {
                          if (!_selectedFilters[filterKey]!.contains(option)) {
                            _selectedFilters[filterKey]!.add(option);
                          }
                        } else {
                          _selectedFilters[filterKey]!.remove(option);
                        }
                      });
                      _applyFilters();
                    },
                  ),
                  Expanded(child: Text(option)),
                ],
              ),
            ),
          );
        }).toList(),
        onSelected: (value) {
          // Handle selection is done in checkbox onChanged
        },
      ),
    );
  }

  Widget _buildActiveFiltersDisplay() {
    List<Widget> filterChips = [];
    
    _selectedFilters.forEach((filterType, selectedValues) {
      for (String value in selectedValues) {
        filterChips.add(
          Chip(
            label: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () {
              setState(() {
                _selectedFilters[filterType]!.remove(value);
              });
              _applyFilters();
            },
            backgroundColor: Colors.blue.shade50,
            side: BorderSide(color: Colors.blue.shade200),
          ),
        );
      }
    });
    
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: filterChips,
    );
  }

  bool _hasActiveFilters() {
    return _selectedFilters.values.any((filters) => filters.isNotEmpty);
  }

  void _clearAllFilters() {
    setState(() {
      _selectedFilters.forEach((key, value) => value.clear());
    });
    _applyFilters();
  }

  Widget _buildDevicesList() {
    if (_devices.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredDevices.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No devices found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _filteredDevices.length,
      itemBuilder: (context, index) {
        final device = _filteredDevices[index];
        final deviceInfo = device['deviceInfo'] ?? {};
        final customerDetails = device['customerDetails'] ?? {};
        final locationDetails = device['locationDetails'] ?? {};

        return DeviceCard(
          deviceModel: deviceInfo['model'] ?? 'Unknown',
          serialNumber: deviceInfo['serialNumber'] ?? 'N/A',
          customer: customerDetails['company'] ?? 'Unknown',
          location: locationDetails['city'] ?? 'Unknown',
          lastService: deviceInfo['installationDate'] ?? 'N/A',
          onEdit: () => _editDevice(device),
          onService: () => _serviceDevice(device),
          onView: () => _viewDeviceDetails(device),
          onDelete: () => _deleteDevice(deviceInfo['serialNumber'] ?? ''),
        );
      },
    );
  }

  void _viewDeviceDetails(Map<String, dynamic> device) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: const CustomAppBar(title: 'Device Details'),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildDeviceDetailsView(device),
          ),
          bottomNavigationBar: BottomNavigation(
            currentIndex: 1,
            onTap: (index) {
              switch (index) {
                case 0:
                  Navigator.pushReplacementNamed(context, '/home');
                  break;
                case 1:
                  Navigator.pushReplacementNamed(context, '/alldevice');
                  break;
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
        ),
      ),
    );
  }


  void _editDevice(Map<String, dynamic> device){
    Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: const CustomAppBar(title: 'Edit Device Details'),
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: DeviceForm(deviceToEdit: device),
                  ),
          
                ),
              ),
            );
  }

  void _serviceDevice(Map<String, dynamic> device){
    Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  body: 
                   NewServiceRequestPage(deviceToService: device),
                  ),
          
                ),
              
            );
  }

  Widget _buildDeviceDetailsView(Map<String, dynamic> device) {
    final deviceInfo = device['deviceInfo'] ?? {};
    final customerDetails = device['customerDetails'] ?? {};
    final locationDetails = device['locationDetails'] ?? {};
    final maintenanceContract = device['maintenanceContract'] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailSection('Device Information', [
          _buildDetailRow('Model', deviceInfo['model'] ?? 'N/A'),
          _buildDetailRow('Serial Number', deviceInfo['serialNumber'] ?? 'N/A'),
          _buildDetailRow('Dispenser', deviceInfo['dispenserDetails'] ?? 'N/A'),
          _buildDetailRow('Power Source', deviceInfo['powerSource'] ?? 'N/A'),
          _buildDetailRow('Installation Date', deviceInfo['installationDate'] ?? 'N/A'),
        ]),
        const SizedBox(height: 20),
        _buildDetailSection('Customer Details', [
          _buildDetailRow('Name', customerDetails['name'] ?? 'N/A'),
          _buildDetailRow('Company', customerDetails['company'] ?? 'N/A'),
          _buildDetailRow('Phone', customerDetails['phone'] ?? 'N/A'),
          _buildDetailRow('Email', customerDetails['email'] ?? 'N/A'),
        ]),
        const SizedBox(height: 20),
        _buildDetailSection('Location Details', [
          _buildDetailRow('City', locationDetails['city'] ?? 'N/A'),
          _buildDetailRow('State', locationDetails['state'] ?? 'N/A'),
          _buildDetailRow('Full Address', locationDetails['fullAddress'] ?? 'N/A'),
        ]),
        const SizedBox(height: 20),
        _buildDetailSection('Maintenance Contract', [
          _buildDetailRow('Annual Contract', maintenanceContract['annualContract'] == true ? 'Yes' : 'No'),
          _buildDetailRow('AMC Type', maintenanceContract['amcType'] ?? 'N/A'),
          _buildDetailRow('AMC Start Date', maintenanceContract['amcStartDate'] ?? 'N/A'),
          _buildDetailRow('AMC End Date', maintenanceContract['amcEndDate'] ?? 'N/A'),
        ]),
      ],
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Card(
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(255, 95, 95, 95),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style:  TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[850],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDevice(String serialNumber) async {
    if (serialNumber.isEmpty) {
      _showSnackBar('Invalid serial number', isError: true);
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final success = await AdminAction.deleteDevice(serialNumber);
      
      // Hide loading indicator
      Navigator.of(context).pop();

      if (success) {
        // Remove device from local lists
        setState(() {
          _devices.removeWhere((device) => 
            device['deviceInfo']?['serialNumber'] == serialNumber);
          _filteredDevices.removeWhere((device) => 
            device['deviceInfo']?['serialNumber'] == serialNumber);
        });
        
        _showSnackBar('Device deleted successfully');
      } else {
        _showSnackBar('Failed to delete device', isError: true);
      }
    } catch (e) {
      // Hide loading indicator
      Navigator.of(context).pop();
      _showSnackBar('Error deleting device: $e', isError: true);
    }
  }

  void _showDeleteConfirmation(String serialNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Device'),
          content: Text('Are you sure you want to delete device with serial number: $serialNumber?\n\nThis action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteDevice(serialNumber);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}