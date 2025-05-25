import 'package:flutter/material.dart';
import 'custom_text_field.dart';

class CustomerDetailsSection extends StatefulWidget {
  const CustomerDetailsSection({Key? key}) : super(key: key);

  @override
  State<CustomerDetailsSection> createState() => CustomerDetailsSectionState();
}

class CustomerDetailsSectionState extends State<CustomerDetailsSection> {
  final nameController = TextEditingController();
  final companyController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final fullAddressController = TextEditingController();
  
  bool enableMaintenanceContract = false;
    Map<String, dynamic> get customerData => {
    'name': nameController.text,
    'company': companyController.text,
    'phone': phoneController.text,
    'email': emailController.text,
    'city': cityController.text,
    'state': stateController.text,
    'address': fullAddressController.text,
    'maintenanceContract': enableMaintenanceContract,
  };

  bool validate() {
    if (nameController.text.isEmpty) return false;
    if (phoneController.text.isEmpty) return false;
    if (emailController.text.isEmpty || 
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailController.text)) {
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    nameController.dispose();
    companyController.dispose();
    phoneController.dispose();
    emailController.dispose();
    cityController.dispose();
    stateController.dispose();
    fullAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Customer Details Section
        Container(
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
                'Customer Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              // Name Field
              CustomTextField(
                label: 'Name',
                controller: nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter customer name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Company Field
              CustomTextField(
                label: 'Company',
                controller: companyController,
              ),
              const SizedBox(height: 16),
              
              // Phone Field
              CustomTextField(
                label: 'Phone',
                controller: phoneController,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Email Field
              CustomTextField(
                label: 'Email',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email address';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Location Details Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),)
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Location Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              // City Field
              CustomTextField(
                label: 'City',
                controller: cityController,
              ),
              const SizedBox(height: 16),
              
              // State Field
              CustomTextField(
                label: 'State',
                controller: stateController,
              ),
              const SizedBox(height: 16),
              
              // Full Address Field
              CustomTextField(
                label: 'Full Address',
                controller: fullAddressController,
                maxLines: 3,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Maintenance Contract Section
        Container(
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
                'Maintenance Contract',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              // Maintenance Contract Checkbox
              Row(
                children: [
                  Checkbox(
                    value: enableMaintenanceContract,
                    onChanged: (value) {
                      setState(() {
                        enableMaintenanceContract = value ?? false;
                      });
                    },
                  ),
                  const Text(
                    'Enable Annual Maintenance Contract',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
      

            ],
          ),
        ),
      ],
    );
  }
}