import 'package:flutter/material.dart';
import 'package:vayujal/screens/all_devices.dart';
import 'device_information_section.dart';
import 'customer_details_section.dart';

class DeviceForm extends StatefulWidget {
  const DeviceForm({Key? key,this.deviceToEdit}) : super(key: key);

  final Map<String, dynamic>? deviceToEdit;

  // const DeviceForm({Key? key, this.deviceToEdit}) : super(key: key);

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
void initState() {
  super.initState();

  if (widget.deviceToEdit != null) {
    final device = widget.deviceToEdit!;
    final deviceInfo = device['deviceInfo'];
    final customer = device['customerDetails'];
    final location = device['locationDetails'];
    final maintenance = device['maintenanceContract'];

    _selectedModel = deviceInfo['model'];
    _serialNumberController.text = deviceInfo['serialNumber'];
    _installationDateController.text = deviceInfo['installationDate'];
    _selectedDispenser = deviceInfo['dispenserDetails'];
    _selectedPowerSource = deviceInfo['powerSource'];
    _uploadedPhotos = List<String>.from(deviceInfo['uploadedPhotos'] ?? []);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _customerDetailsKey.currentState?.nameController.text = customer['name'];
      _customerDetailsKey.currentState?.companyController.text = customer['company'];
      _customerDetailsKey.currentState?.phoneController.text = customer['phone'];
      _customerDetailsKey.currentState?.emailController.text = customer['email'];
      _customerDetailsKey.currentState?.cityController.text = location['city'];
      _customerDetailsKey.currentState?.stateController.text = location['state'];
      _customerDetailsKey.currentState?.fullAddressController.text = location['fullAddress'];
      _customerDetailsKey.currentState?.enableMaintenanceContract = maintenance['annualContract'];
    });
  }
}


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
    final customerState = _customerDetailsKey.currentState!;

    final formData = {
      'deviceInfo': {
        'model': _selectedModel,
        'serialNumber': _serialNumberController.text,
        'dispenserDetails': _selectedDispenser ?? '',
        'powerSource': _selectedPowerSource ?? '',
        'installationDate': _installationDateController.text,
        'uploadedPhotos': _uploadedPhotos, // Make sure it's serializable
      },
      'customerDetails': {
        'name': customerState.nameController.text,
        'company': customerState.companyController.text,
        'phone': customerState.phoneController.text,
        'email': customerState.emailController.text,
      },
      'locationDetails': {
        'city': customerState.cityController.text,
        'state': customerState.stateController.text,
        'fullAddress': customerState.fullAddressController.text,
      },
      'maintenanceContract': {
        'annualContract': customerState.enableMaintenanceContract,
      }
    };
    print(formData);

    // Example usage: pass to DevicesScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DevicesScreen(newDevice: formData),
      ),
    );
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
               child: Text(
  widget.deviceToEdit != null ? 'Save Changes' : 'Register Device',
  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
),

            ),
          ),
        ],
      ),
    );
  }
}
