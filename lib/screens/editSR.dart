import 'package:flutter/material.dart';
import 'package:vayujal/DatabaseAction/adminAction.dart';

class EditServiceRequestDialog extends StatefulWidget {
  final Map<String, dynamic> serviceRequest;
  final VoidCallback onUpdated;

  const EditServiceRequestDialog({
    super.key,
    required this.serviceRequest,
    required this.onUpdated,
  });

  @override
  State<EditServiceRequestDialog> createState() => _EditServiceRequestDialogState();
}

class _EditServiceRequestDialogState extends State<EditServiceRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _commentsController = TextEditingController();
  
  List<Map<String, dynamic>> _technicians = [];
  bool _isLoadingTechnicians = true;
  bool _isUpdating = false;
  
  String? _selectedTechnician;
  String? _selectedStatus;
  DateTime? _selectedDate;
  String? _selectedRequestType;
  String? _selectedTechnicianName; // This will store "name - empId"

  final List<String> _statusOptions = ['pending', 'in_progress', 'completed', 'delayed'];
  final List<String> _requestTypeOptions = ['general_maintenance', 'customer_complaint'];

  @override
  void initState() {
    super.initState();
    _initializeData();
    _loadTechnicians();
  }

  void _initializeData() {
    final serviceDetails = widget.serviceRequest['serviceDetails'] ?? {};
    
    _selectedTechnician = serviceDetails['assignedTo'];
    _selectedStatus = widget.serviceRequest['status'] ?? 'pending';
    _commentsController.text = serviceDetails['comments'] ?? '';
    _selectedRequestType = serviceDetails['requestType'] ?? 'general_maintenance';
    _selectedTechnicianName = serviceDetails['assignedTechnician'] ?? 'Unassigned';
    
    // Parse address by date
    if (serviceDetails['addressByDate'] != null) {
      try {
        _selectedDate = serviceDetails['addressByDate'].toDate();
      } catch (e) {
        _selectedDate = DateTime.now().add(const Duration(days: 2));
      }
    } else {
      _selectedDate = DateTime.now().add(const Duration(days: 2));
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
      });

      // If current technician is not in the list, update the selected technician name
      _updateTechnicianName();
    } catch (e) {
      setState(() {
        _isLoadingTechnicians = false;
      });
      print("Error loading technicians: $e");
    }
  }

  // Helper method to get technician name by empId
  String? _getTechnicianNameById(String? empId) {
    if (empId == null) return null;
    
    final technician = _technicians.firstWhere(
      (tech) => tech['empId'] == empId,
      orElse: () => {},
    );
    
    if (technician.isNotEmpty) {
      return '${technician['name']} - ${technician['empId']}';
    }
    return null;
  }

  // Update technician name when technicians are loaded or selected
  void _updateTechnicianName() {
    if (_selectedTechnician != null) {
      String? techName = _getTechnicianNameById(_selectedTechnician);
      if (techName != null) {
        setState(() {
          _selectedTechnicianName = techName;
        });
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 2)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _updateServiceRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      String srId = widget.serviceRequest['srId'] ?? widget.serviceRequest['serviceDetails']?['srId'] ?? '';
      
      bool success = await AdminAction.updateServiceRequest(
        srId: srId,
        newAssignedTo: _selectedTechnician,
        status: _selectedStatus,
        comments: _commentsController.text.trim(),
        newAddressByDate: _selectedDate,
        requestType: _selectedRequestType,
        assignedTechnician: _selectedTechnicianName, // Send the formatted "name - empId"
      );

      if (success) {
        Navigator.of(context).pop();
        widget.onUpdated();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service request updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Debug print
        debugPrint('=== Service Request Updated ===');
        debugPrint('SR ID: $srId');
        debugPrint('Assigned To (EmpId): $_selectedTechnician');
        debugPrint('Assigned Technician (Name - EmpId): $_selectedTechnicianName');
        debugPrint('Status: $_selectedStatus');
        debugPrint('Request Type: $_selectedRequestType');
        debugPrint('Address By Date: $_selectedDate');
        debugPrint('Comments: ${_commentsController.text.trim()}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating service request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final srId = widget.serviceRequest['srId'] ?? 
                 widget.serviceRequest['serviceDetails']?['srId'] ?? 'N/A';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Edit Service Request',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'SR ID: $srId',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Body
            Flexible(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Assign Technician
                      const Text(
                        'Assign Technician',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_isLoadingTechnicians)
                        const Center(child: CircularProgressIndicator())
                      else
                        DropdownButtonFormField<String>(
                          value: _selectedTechnician,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Select technician',
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('Unassigned'),
                            ),
                            ..._technicians.map((tech) {
                              return DropdownMenuItem<String>(
                                value: tech['empId'],
                                child: Text('${tech['name']} (${tech['empId']})'),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedTechnician = value;
                              _selectedTechnicianName = _getTechnicianNameById(value);
                            });
                          },
                        ),

                      const SizedBox(height: 16),

                      // Status
                      const Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: _statusOptions.map((status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status.replaceAll('_', ' ').toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Request Type
                      const Text(
                        'Request Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedRequestType,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: _requestTypeOptions.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type.replaceAll('_', ' ').toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRequestType = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Address By Date
                      const Text(
                        'Address By Date',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, color: Colors.grey.shade600),
                              const SizedBox(width: 8),
                              Text(
                                _selectedDate != null 
                                    ? _formatDate(_selectedDate!)
                                    : 'Select date',
                                style: TextStyle(
                                  color: _selectedDate != null 
                                      ? Colors.black87 
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Comments
                      const Text(
                        'Comments',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _commentsController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Add comments...',
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isUpdating ? null : _updateServiceRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: _isUpdating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Update'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}