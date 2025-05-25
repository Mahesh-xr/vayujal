import 'package:flutter/material.dart';
import 'device_information_section.dart';
import 'customer_details_section.dart';

class DeviceForm extends StatefulWidget {
  const DeviceForm({Key? key}) : super(key: key);

  @override
  State<DeviceForm> createState() => _DeviceFormState();
}

class _DeviceFormState extends State<DeviceForm> {
  final _formKey = GlobalKey<FormState>();
  final _serialNumberController = TextEditingController();
  final _installationDateController = TextEditingController();


  final _customerDetailsKey = GlobalKey<CustomerDetailsSectionState>();


  String? _selectedModel;
  String? _selectedDispenser;
  String? _selectedPowerSource;
  List<String> _uploadedPhotos = [];

  @override
  void dispose() {
    _serialNumberController.dispose();
    _installationDateController.dispose();
    super.dispose();
  }

  void _handlePhotoUpload(List<String> photos) {
    setState(() {
      _uploadedPhotos = photos;
    });
  }

  void _handleModelSelection(String? model) {
    setState(() {
      _selectedModel = model;
    });
  }

  void _handleDispenserSelection(String? dispenser) {
    setState(() {
      _selectedDispenser = dispenser;
    });
  }

  void _handlePowerSourceSelection(String? powerSource) {
    setState(() {
      _selectedPowerSource = powerSource;
    });
  }



  void _printAllFormData() {
    if (_formKey.currentState!.validate()) {
      // Device information
      print('=== DEVICE INFORMATION ===');
      print('Model: $_selectedModel');
      print('Serial Number: ${_serialNumberController.text}');
      print('Dispenser Details: $_selectedDispenser');
      print('Power Source: $_selectedPowerSource');
      print('Installation Date: ${_installationDateController.text}');
      print('Uploaded Photos: $_uploadedPhotos');

      // Customer information (accessed via the key)
      final customerState = _customerDetailsKey.currentState!;
      print('\n=== CUSTOMER DETAILS ===');
      print('Name: ${customerState.nameController.text}');
      print('Company: ${customerState.companyController.text}');
      print('Phone: ${customerState.phoneController.text}');
      print('Email: ${customerState.emailController.text}');
      
      print('\n=== LOCATION DETAILS ===');
      print('City: ${customerState.cityController.text}');
      print('State: ${customerState.stateController.text}');
      print('Full Address: ${customerState.fullAddressController.text}');
      
      print('\n=== MAINTENANCE CONTRACT ===');
      print('Annual Maintenance Contract: ${customerState.enableMaintenanceContract}');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DeviceInformationSection(
            selectedModel: _selectedModel,
            uploadedPhotos: _uploadedPhotos,
            serialNumberController: _serialNumberController,
            selectedDispenser: _selectedDispenser,
            selectedPowerSource: _selectedPowerSource,
            installationDateController: _installationDateController,
            onModelChanged: _handleModelSelection,
            onPhotosUploaded: _handlePhotoUpload,
            onDispenserChanged: _handleDispenserSelection,
            onPowerSourceChanged: _handlePowerSourceSelection,
          ),
          const SizedBox(height: 24),
          CustomerDetailsSection(key: _customerDetailsKey),
          Container(
            width: double.infinity, // Makes the button full width
            margin: const EdgeInsets.only(top: 20),
            child: ElevatedButton(
              onPressed: () {
             _printAllFormData();              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Button color
                foregroundColor: Colors.white, // Text color
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2, // Shadow
              ),
              child: const Text(
                'Register Device',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
