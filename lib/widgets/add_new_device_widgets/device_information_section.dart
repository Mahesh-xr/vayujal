import 'package:flutter/material.dart';
import 'custom_dropdown.dart';
import 'photo_upload_widget.dart';
import 'custom_text_field.dart';
import 'date_picker_field.dart';

class DeviceInformationSection extends StatelessWidget {
  final String? selectedModel;
  final List<String> uploadedPhotos;
  final TextEditingController serialNumberController;
  final String? selectedDispenser;
  final String? selectedPowerSource;
  final TextEditingController installationDateController;
  final Function(String?) onModelChanged;
  final Function(List<String>) onPhotosUploaded;
  final Function(String?) onDispenserChanged;
  final Function(String?) onPowerSourceChanged;

  const DeviceInformationSection({
    Key? key,
    required this.selectedModel,
    required this.uploadedPhotos,
    required this.serialNumberController,
    required this.selectedDispenser,
    required this.selectedPowerSource,
    required this.installationDateController,
    required this.onModelChanged,
    required this.onPhotosUploaded,
    required this.onDispenserChanged,
    required this.onPowerSourceChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Device Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // Model Dropdown
          CustomDropdown(
            label: 'Model',
            value: selectedModel,
            items: const ['AWG Model', 'VJ - Home', 'VJ - Plus', 'VJ - Grand' ,'VJ - Ultra', 'VJ - Max'],
            onChanged: onModelChanged,
          ),
          const SizedBox(height: 16),
          
          // Photo Upload
          PhotoUploadWidget(
            uploadedPhotos: uploadedPhotos,
            onPhotosUploaded: onPhotosUploaded,
          ),
          const SizedBox(height: 16),
          
          // Serial Number
          CustomTextField(
            label: 'Compressor Serial Number',
            controller: serialNumberController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter serial number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Dispenser Details
          CustomDropdown(
            label: 'Dispenser Details',
            value: selectedDispenser,
            items: const ['Select', 'Standard Dual Dispenser', 'Premium Dispenser', 'Custom Configuration'],
            onChanged: onDispenserChanged,
          ),
          const SizedBox(height: 16),
          
          // Power Source
          CustomDropdown(
            label: 'Power source',
            value: selectedPowerSource,
            items: const ['Select', '220V AC', '110V AC', ],
            onChanged: onPowerSourceChanged,
          ),
          const SizedBox(height: 16),
          
          // Installation Date
          DatePickerField(
            label: 'Installation Date',
            controller: installationDateController,
            hintText: 'dd-mm-yyyy',
          ),
        ],
      ),
    );
  }
}