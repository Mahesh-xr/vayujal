import 'package:flutter/material.dart';
import 'package:vayujal/DatabaseAction/adminAction.dart';
import 'package:vayujal/screens/service_hostory_screen.dart';
import 'package:vayujal/widgets/new_service_request_widgets/submit_botton.dart';

class ServiceDetailsPage extends StatefulWidget {
  final String serviceRequestId;
  
  const ServiceDetailsPage({
    super.key,
    required this.serviceRequestId,
  });

  @override
  State<ServiceDetailsPage> createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ServiceDetailsPage> {
  Map<String, dynamic>? _serviceRequest;
  Map<String, dynamic>? _serviceHistory;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServiceRequestDetails();
  }

  Future<void> _loadServiceRequestDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic>? serviceRequest = await AdminAction.getServiceRequestById(widget.serviceRequestId);
      Map<String, dynamic>? serviceHistory = await AdminAction.getServiceHistoryBySrId(widget.serviceRequestId);
      
      setState(() {
        _serviceRequest = serviceRequest;
        _serviceHistory = serviceHistory;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading service request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    
    try {
      DateTime date;
      if (timestamp is String) {
        date = DateTime.parse(timestamp);
      } else {
        date = timestamp.toDate();
      }
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }

  String _formatDateTime(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    
    try {
      DateTime date;
      if (timestamp is String) {
        date = DateTime.parse(timestamp);
      } else {
        date = timestamp.toDate();
      }
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }

  Widget _buildDetailCard(String title, Widget content) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'N/A',
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildChipList(String label, dynamic items) {
  //   // Handle different data types
  //   List<dynamic> itemList = [];
    
  //   if (items == null) {
  //     return _buildDetailRow(label, 'None');
  //   } else if (items is List) {
  //     itemList = items;
  //   } else if (items is String) {
  //     // If it's a single string, convert to list
  //     if (items.isNotEmpty) {
  //       itemList = [items];
  //     }
  //   } else {
  //     // For any other type, convert to string and add to list
  //     itemList = [items.toString()];
  //   }

  //   if (itemList.isEmpty) {
  //     return _buildDetailRow(label, 'None');
  //   }

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         '$label:',
  //         style: TextStyle(
  //           fontWeight: FontWeight.w500,
  //           color: Colors.grey[700],
  //         ),
  //       ),
  //       const SizedBox(height: 8),
  //       Wrap(
  //         spacing: 8,
  //         runSpacing: 4,
  //         children: itemList.map<Widget>((item) => Chip(
  //           label: Text(
  //             item.toString(),
  //             style: const TextStyle(fontSize: 12),
  //           ),
  //           backgroundColor: Colors.blue.shade50,
  //           labelStyle: TextStyle(color: Colors.blue.shade700),
  //         )).toList(),
  //       ),
  //       const SizedBox(height: 12),
  //     ],
  //   );
  // }


  Widget _buildChipList(String label, dynamic items) {
  // Handle different data types
  List<dynamic> itemList = [];

  if (items == null) {
    return _buildDetailRow(label, 'None');
  } else if (items is List) {
    itemList = items;
  } else if (items is String) {
    if (items.isNotEmpty) {
      itemList = [items];
    }
  } else {
    itemList = [items.toString()];
  }

  if (itemList.isEmpty) {
    return _buildDetailRow(label, 'None');
  }

  // Convert list to comma-separated string
  String itemText = itemList.join(', ');

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '$label:',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.grey[700],
        ),
      ),
      const SizedBox(height: 8),
      Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          itemText,
          style: TextStyle(
            fontSize: 13,
            color: Colors.blue.shade700,
          ),
          softWrap: true,           // ✅ Ensures text wraps
          overflow: TextOverflow.visible, // ✅ Ensures no cut-off
        ),
      ),
      const SizedBox(height: 12),
    ],
  );
}


  Widget _buildEquipmentDetails() {
    Map<String, dynamic> equipmentDetails = _serviceRequest?['equipmentDetails'] ?? {};
    
    return _buildDetailCard(
      'VJ AWG Details',
      Column(
        children: [
          _buildDetailRow('Model', equipmentDetails['model'] ?? ''),
          _buildDetailRow('Serial Number', equipmentDetails['awgSerialNumber'] ?? ''),
          _buildDetailRow('City', equipmentDetails['city'] ?? ''),
          _buildDetailRow('State', equipmentDetails['state'] ?? ''),
          _buildDetailRow('Owner', equipmentDetails['owner'] ?? ''),
        ],
      ),
    );
  }

  Widget _buildOwnerDetails() {
    Map<String, dynamic> customerDetails = _serviceRequest?['customerDetails'] ?? {};
    
    return _buildDetailCard(
      'Owner Details',
      Column(
        children: [
          _buildDetailRow('Name', customerDetails['name'] ?? ''),
          _buildDetailRow('Company', customerDetails['company'] ?? ''),
          _buildDetailRow('Mobile', customerDetails['phone'] ?? ''),
          _buildDetailRow('Email', customerDetails['email'] ?? ''),
          _buildDetailRow('Address', customerDetails['address']['fullAddress'] ?? ''),
        ],
      ),
    );
  }

  Widget _buildServiceHistory() {
    // Check if service history exists
    Map<String, dynamic> serviceDetails = _serviceRequest?['equipmentDetails']['amcDetails'] ?? {};
    
    return _buildDetailCard(
      'Service History',
      Column(
        children: [
          _buildDetailRow('AMC Start', (serviceDetails['amcStartDate'] ?? '')),
          _buildDetailRow('AMC End', (serviceDetails['amcEndDate'] ?? '')),
          _buildDetailRow('AMC Type', (serviceDetails['amcType'] ?? '')),
          _buildDetailRow("Annual Contact", (serviceDetails['annualContract'] ? 'yes':'no')),
          SubmitButton(
            text: "View Full History",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceHistoryScreen(
                    serialNumber: _serviceRequest?['deviceId'],
                  ),
                ),
              );
            }
          )
        ],
      ),
    );
  }

  Widget _buildComplaintDetails() {
    Map<String, dynamic> serviceDetails = _serviceRequest?['serviceDetails'] ?? {};
    String requestType = serviceDetails['requestType'] ?? '';
    String description = serviceDetails['description'] ?? '';
    String comments = serviceDetails['comments'] ?? '';
    
    // Only show complaint details if it's a customer complaint
    if (requestType.toLowerCase().contains('complaint') || 
        description.isNotEmpty || 
        comments.isNotEmpty) {
      
      return _buildDetailCard(
        'Complaint Details',
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (comments.isNotEmpty && comments != description) ...[
              const Text(
                'Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                comments,
                style: const TextStyle(
                  color: Colors.black87,
                ),
              ),
            ],
          ],
        ),
      );
    }
    
    return const SizedBox.shrink();
  }


  Widget buildLabeledContent({
  required String title,
  required String content,
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.normal,
  Color? textColor,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: fontSize + 2,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        content,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor ?? Colors.black87,
        ),
      ),
    ],
  );
}


  Widget _buildServiceExecutionDetails() {
    // Only show if service history exists
    if (_serviceHistory == null) {
      return const SizedBox.shrink();
    }

    return _buildDetailCard(
      'Service Execution Details',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Status', (_serviceHistory!['status'] ?? '').toString().replaceAll('_', ' ').toUpperCase()),
          _buildDetailRow('Complaint \nRelated To', _serviceHistory!['complaintRelatedTo'] ?? ''),
          _buildDetailRow('Type of Issue Raised', _serviceHistory!['typeOfRaisedIssue'] ?? ''),
          _buildDetailRow('Issue Type', _serviceHistory!['issueType'] ?? ''),
          const SizedBox(height: 8),
          _buildChipList('Issue Identification', _serviceHistory!['issueIdentification']),
          _buildChipList('Parts Replaced', _serviceHistory!['partsReplaced']),
         
        ],
      ),
    );
  }

  Widget _buildTechnicianDetails() {
    if (_serviceHistory == null) {
      return const SizedBox.shrink();
    }

    return _buildDetailCard(
      'Technician Details',
      Column(
        children: [
          _buildDetailRow('Technician Name', _serviceHistory!['technician'] ?? ''),
          _buildDetailRow('Employee ID', _serviceHistory!['empId'] ?? ''),
          _buildDetailRow('Resolved By ID', _serviceHistory!['resolvedBy'] ?? ''),
          _buildDetailRow('Service Date', _formatDateTime(_serviceHistory!['timestamp'])),
          _buildDetailRow('Resolution Date', _formatDateTime(_serviceHistory!['resolutionTimestamp'])),
          _buildDetailRow('Next Service Date', _formatDate(_serviceHistory!['nextServiceDate'])),
        ],
      ),
    );
  }

  Widget _buildMaintenanceSuggestions() {
    if (_serviceHistory == null || _serviceHistory!['suggestions'] == null) {
      return const SizedBox.shrink();
    }

    Map<String, dynamic> suggestions = _serviceHistory!['suggestions'];
    List<Widget> suggestionWidgets = [];

    suggestions.forEach((key, value) {
      if (value == true) {
        String readableKey = key.replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(1)}',
        ).toLowerCase();
        readableKey = readableKey[0].toUpperCase() + readableKey.substring(1);
        
        suggestionWidgets.add(
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade600, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    readableKey,
                    style: TextStyle(color: Colors.green.shade700),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });

    if (suggestionWidgets.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildDetailCard(
      'Maintenance Suggestions',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: suggestionWidgets,
      ),
    );
  }

  Widget _buildImageGallery() {
    if (_serviceHistory == null) {
      return const SizedBox.shrink();
    }

    List<String> allImageUrls = [];
    
    // Helper function to safely extract URLs from different data types
    List<String> extractUrls(dynamic urlData) {
      if (urlData == null) return [];
      if (urlData is List) {
        return urlData.map((url) => url.toString()).toList();
      } else if (urlData is String && urlData.isNotEmpty) {
        return [urlData];
      }
      return [];
    }
    
    // Add all image URLs safely
    allImageUrls.addAll(extractUrls(_serviceHistory!['frontViewImageUrls']));
    allImageUrls.addAll(extractUrls(_serviceHistory!['leftViewImageUrls']));
    allImageUrls.addAll(extractUrls(_serviceHistory!['rightViewImageUrls']));
    allImageUrls.addAll(extractUrls(_serviceHistory!['issueImageUrls']));
    allImageUrls.addAll(extractUrls(_serviceHistory!['resolutionImageUrl']));

    if (allImageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildDetailCard(
      'Service Images',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: allImageUrls.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      allImageUrls[index],
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 120,
                          height: 120,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          if (_serviceHistory!['issueVideoUrl'] != null && _serviceHistory!['issueVideoUrl'].toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                // Handle video viewing
                // You can implement video player or open in browser
              },
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('View Issue Video'),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Service Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _serviceRequest == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Service request not found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadServiceRequestDetails,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Service Request Header
                        Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [Colors.blue.shade600, Colors.blue.shade400],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _serviceRequest?['serviceDetails']?['srId'] ?? 
                                  _serviceRequest?['srId'] ?? 
                                  'Service Request',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Status: ${(_serviceRequest?['serviceDetails']?['status'] ?? _serviceRequest?['status'] ?? 'pending').toString().replaceAll('_', ' ').toUpperCase()}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                                if (_serviceHistory != null) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Service Completed',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        // Equipment Details
                        _buildEquipmentDetails(),

                        // Owner Details
                        _buildOwnerDetails(),

                        // Service History
                        _buildServiceHistory(),

                        // Complaint Details (conditional)
                        _buildComplaintDetails(),

                        // Service Execution Details (only if service history exists)
                        _buildServiceExecutionDetails(),

                        // Technician Details (only if service history exists)
                        _buildTechnicianDetails(),
                        
                        _buildDetailCard('suggestion',  buildLabeledContent(title: 'Solution Provided',content:  _serviceHistory!['solutionProvided'] ?? ''),),
                        _buildDetailCard('custom suggestion',  buildLabeledContent(title: 'Custom Suggestions',content:  _serviceHistory!['customSuggestions'] ?? ''),),
                        // Maintenance Suggestions (only if service history exists)
                        _buildMaintenanceSuggestions(),

                        // Image Gallery (only if service history exists)
                        _buildImageGallery(),
                      ],
                    ),
                  ),
                ),
    );
  }
}