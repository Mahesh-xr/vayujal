import 'package:flutter/material.dart';
import 'package:vayujal/widgets/navigations/custom_app_bar.dart';
import 'package:vayujal/widgets/new_service_request_widgets/customer_detials_form.dart';
import 'package:vayujal/widgets/new_service_request_widgets/equipment_details_form.dart';
import 'package:vayujal/widgets/new_service_request_widgets/service_request_detials_widget.dart';
import 'package:vayujal/widgets/new_service_request_widgets/submit_botton.dart';

class NewServiceRequestPage extends StatefulWidget {
  final Map<String, dynamic>? deviceToService;
  
  const NewServiceRequestPage({super.key, this.deviceToService});

  @override
  State<NewServiceRequestPage> createState() => _NewServiceRequestPageState();
}

class _NewServiceRequestPageState extends State<NewServiceRequestPage> {
  final _formKey = GlobalKey<FormState>();
  int _selectedBottomNavIndex = 0;

  // Equipment Details Controllers
  final _modelController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _ownerController = TextEditingController();
  final _awgSerialNumberController = TextEditingController();

  // Customer Details Controllers
  final _customerIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  // SR Details Controllers
  final _commentController = TextEditingController();
  bool _generalMaintenance = false;
  bool _customerComplaint = false; // Default to true for demo
  String? _assignedTo = 'Tech Team A'; // Default assignment
  DateTime? _addressByDate = DateTime.now().add(const Duration(days: 2)); // Default 2 days from now

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    if (widget.deviceToService != null) {
      // Load data from the selected device
      _loadDeviceData(widget.deviceToService!);
    }
    // If no device is provided, leave fields empty for manual entry
  }

  void _loadDeviceData(Map<String, dynamic> device) {
    final deviceInfo = device['deviceInfo'] ?? {};
    final customerDetails = device['customerDetails'] ?? {};
    final locationDetails = device['locationDetails'] ?? {};

    // Equipment data from device
    _modelController.text = deviceInfo['model'] ?? '';
    _awgSerialNumberController.text = deviceInfo['awgSerialNumber'] ?? '';
    _cityController.text = locationDetails['city'] ?? '';
    _stateController.text = locationDetails['state'] ?? '';
    _ownerController.text = customerDetails['name'] ?? '';

    // Customer data from device
    _nameController.text = customerDetails['name'] ?? '';
    _companyController.text = customerDetails['company'] ?? '';
    _phoneController.text = customerDetails['phone'] ?? '';
    _emailController.text = customerDetails['email'] ?? '';
    
    // Generate customer ID based on serial number or timestamp
    final serialNumber = deviceInfo['serialNumber'] ?? '';
    if (serialNumber.isNotEmpty) {
      _customerIdController.text = 'CUST_${serialNumber}';
    } else {
      _customerIdController.text = 'CUST_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    }

    // SR Details - pre-fill with device context
    final deviceModel = deviceInfo['model'] ?? 'device';
    final deviceSerial = deviceInfo['serialNumber'] ?? 'N/A';
    _commentController.text = 'Service request for $deviceModel (Serial: $deviceSerial)';
  }

  @override
  void dispose() {
    _modelController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _ownerController.dispose();
    _customerIdController.dispose();
    _nameController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedBottomNavIndex = index;
    });
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Service request created successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Print all form data to console for debugging
      debugPrint('=== Service Request Details ===');
      debugPrint('Equipment Model: ${_modelController.text}');
      debugPrint('AWG Serial Number: ${_awgSerialNumberController.text}');
      debugPrint('Location: ${_cityController.text}, ${_stateController.text}');
      debugPrint('Customer: ${_nameController.text} (${_companyController.text})');
      debugPrint('Contact: ${_phoneController.text} | ${_emailController.text}');
      debugPrint('Complaint Type: ${_customerComplaint ? 'Customer Complaint' : 'General Maintenance'}');
      debugPrint('Assigned To: $_assignedTo');
      debugPrint('Address By: $_addressByDate');
      debugPrint('Comments: ${_commentController.text}');
      
      // Navigate back to devices screen after successful submission
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: 'New Service Request',
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          
              EquipmentDetailsForm(
                modelController: _modelController,
                cityController: _cityController,
                stateController: _stateController,
                ownerController: _ownerController,
                awgSerialNumberController: _awgSerialNumberController,
              ),
              const SizedBox(height: 24),
              CustomerDetailsForm(
                nameController: _nameController,
                companyController: _companyController,
                phoneController: _phoneController,
                emailController: _emailController,
                customerIdController: _customerIdController,
              ),
              const SizedBox(height: 24),
              ServiceRequestDetailsWidget(
                commentController: _commentController,
                generalMaintenance: _generalMaintenance,
                customerComplaint: _customerComplaint,
                assignedTo: _assignedTo,
                addressByDate: _addressByDate,
                onGeneralMaintenanceChanged: (value) {
                  setState(() => _generalMaintenance = value);
                },
                onCustomerComplaintChanged: (value) {
                  setState(() => _customerComplaint = value);
                },
                onAssignedToChanged: (value) {
                  setState(() => _assignedTo = value);
                },
                onAddressByDateChanged: (date) {
                  setState(() => _addressByDate = date);
                },
              ),
              const SizedBox(height: 24),
              SubmitButton(
                onPressed: _onSubmit,
                text: 'Create Service Request',
              ),
            ],
          ),
        ),
      ),
    );
  }
}