import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vayujal/DatabaseAction/adminAction.dart';
import 'package:vayujal/screens/all_service_request_page.dart';
import 'package:vayujal/widgets/navigations/custom_app_bar.dart';
import 'package:vayujal/widgets/new_service_request_widgets/customer_detials_form.dart';
import 'package:vayujal/widgets/new_service_request_widgets/equipment_details_form.dart.dart';
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
  bool _customerComplaint = false;
  String? _assignedTo;
  DateTime? _addressByDate = DateTime.now().add(const Duration(days: 2));

  // Technician dropdown data
  List<Map<String, dynamic>> _technicians = [];
  bool _isLoadingTechnicians = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadTechnicians();
  }

  void _loadData() {
    if (widget.deviceToService != null) {
      _loadDeviceData(widget.deviceToService!);
    }
  }

  Future<void> _loadTechnicians() async {
    try {
      setState(() {
        _isLoadingTechnicians = true;
      });
      
      List<Map<String, dynamic>> techs = await AdminAction.getAllTechnicians();
      
      setState(() {
        _technicians = techs;
        _isLoadingTechnicians = false;
        
        // Set default assignment if technicians are available
        if (techs.isNotEmpty && _assignedTo == null) {
          _assignedTo = techs.first['empId'];
        }
      });
      
      // Debug print
      techs.forEach((tech) {
        print("Technician: ${tech['name']} (Emp ID: ${tech['empId']})");
      });
    } catch (e) {
      setState(() {
        _isLoadingTechnicians = false;
      });
      print("Error loading technicians: $e");
    }
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
   

    // SR Details - pre-fill with device context
   
  }

  // Widget for technician dropdown
  Widget _buildTechnicianDropdown() {
    return Card(
      color:Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assign Technician',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoadingTechnicians)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_technicians.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No technicians available. Please add technicians first.',
                        style: TextStyle(color: Colors.orange.shade800),
                      ),
                    ),
                    TextButton(
                      onPressed: _loadTechnicians,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else
              DropdownButtonFormField<String>(
                value: _assignedTo,
                decoration: const InputDecoration(
                  labelText: 'Select Technician',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                items: [
                  // Option for unassigned
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Unassigned'),
                  ),
                  // Technician options
                  ..._technicians.map((technician) {
                    return DropdownMenuItem<String>(
                      value: technician['empId'],
                      child: Text(
                        '${technician['name']} (${technician['empId']})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                ],
                onChanged: (String? value) {
                  setState(() {
                    _assignedTo = value;
                  });
                },
                validator: (value) {
                  // Optional: Make assignment mandatory
                  // if (value == null || value.isEmpty) {
                  //   return 'Please select a technician';
                  // }
                  return null;
                },
                hint: const Text('Choose a technician'),
              ),
          ],
        ),
      ),
    );
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

  void _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        // Prepare equipment details
        Map<String, dynamic> equipmentDetails = {
          'model': _modelController.text,
          'awgSerialNumber': _awgSerialNumberController.text,
          'city': _cityController.text,
          'state': _stateController.text,
          'owner': _ownerController.text,
        };

        // Prepare customer details
        Map<String, dynamic> customerDetails = {
          'name': _nameController.text,
          'company': _companyController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
        };

        // Prepare service details
        Map<String, dynamic> serviceDetails = {
          'requestType': _customerComplaint ? 'customer_complaint' : 'general_maintenance',          
          'comments': _commentController.text,
          'assignedTo': _assignedTo,
          'addressByDate': _addressByDate != null ? Timestamp.fromDate(_addressByDate!) : null,
        };

        // Create service request
        String srId = await AdminAction.createServiceRequest(
          equipmentDetails: equipmentDetails,
          customerDetails: customerDetails,
          serviceDetails: serviceDetails,
          deviceId: widget.deviceToService?['deviceInfo']?['awgSerialNumber'],
        );

        // If technician is assigned, create task immediately
        if (_assignedTo != null && _assignedTo!.isNotEmpty) {
          try {
            String taskId = await AdminAction.assignTaskToEmployee(
              serviceRequestId: srId,
              employeeId: _assignedTo!,
              assignedBy: 'ADMIN001', // Replace with actual admin ID
            );
            
            debugPrint('✅ Task created and assigned: $taskId');
          } catch (e) {
            debugPrint('⚠️ Service request created but task assignment failed: $e');
          }
        }

        // Hide loading indicator
        Navigator.of(context).pop();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Service request created successfully!\nSR ID: $srId'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Print debug information
        debugPrint('=== Service Request Created ===');
        debugPrint('SR ID: $srId');
        debugPrint('Equipment Model: ${_modelController.text}');
        debugPrint('AWG Serial Number: ${_awgSerialNumberController.text}');
        debugPrint('Location: ${_cityController.text}, ${_stateController.text}');
        debugPrint('Customer: ${_nameController.text} (${_companyController.text})');
        debugPrint('Contact: ${_phoneController.text} | ${_emailController.text}');
        debugPrint('Request Type: ${_customerComplaint ? 'Customer Complaint' : 'General Maintenance'}');
        debugPrint('Assigned To: $_assignedTo');
        debugPrint('Address By: $_addressByDate');
        debugPrint('Comments: ${_commentController.text}');
        
        // Navigate  to all SR request screen
        Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const AllServiceRequestsPage(),
        ),
      );
        
      } catch (e) {
        // Hide loading indicator if showing
        Navigator.of(context).pop();
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating service request: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        
        debugPrint('❌ Error creating service request: $e');
      }
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
              ),
              const SizedBox(height: 24),
              ServiceRequestDetailsWidget(
                commentController: _commentController,
                generalMaintenance: _generalMaintenance,
                customerComplaint: _customerComplaint,
                
                addressByDate: _addressByDate,
                onGeneralMaintenanceChanged: (value) {
                  setState(() => _generalMaintenance = value);
                },
                onCustomerComplaintChanged: (value) {
                  setState(() => _customerComplaint = value);
                },
              
                onAddressByDateChanged: (date) {
                  setState(() => _addressByDate = date);
                },
              ),
              const SizedBox(height: 24),
              // Add the technician dropdown here
              _buildTechnicianDropdown(),
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