import 'package:flutter/material.dart';
import 'package:vayujal/DatabaseAction/adminAction.dart';
import 'package:vayujal/screens/editSR.dart';
import 'package:vayujal/widgets/navigations/NormalAppBar.dart';
import 'package:vayujal/widgets/navigations/bottom_navigation.dart';
import 'package:vayujal/widgets/navigations/custom_app_bar.dart';
import 'package:vayujal/pages/service_details_page.dart';

class AllServiceRequestsPage extends StatefulWidget {
  const AllServiceRequestsPage({super.key});

  @override
  State<AllServiceRequestsPage> createState() => _AllServiceRequestsPageState();
}

class _AllServiceRequestsPageState extends State<AllServiceRequestsPage> {
  List<Map<String, dynamic>> _allServiceRequests = [];
  List<Map<String, dynamic>> _filteredServiceRequests = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filterOptions = ['All', 'Pending','In Progress', 'Delayed', 'Completed'];

  @override
  void initState() {
    super.initState();
    _loadServiceRequests();
  }

  Future<void> _loadServiceRequests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Map<String, dynamic>> serviceRequests = await AdminAction.getAllServiceRequests();
      setState(() {
        _allServiceRequests = serviceRequests;
        _filteredServiceRequests = serviceRequests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading service requests: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterServiceRequests(String filter) {
    setState(() {
      _selectedFilter = filter;
      
      if (filter == 'All') {
        _filteredServiceRequests = _allServiceRequests;
      } else {
        String statusFilter = _getStatusFromFilter(filter);
        _filteredServiceRequests = _allServiceRequests.where((sr) {
          String status = sr['serviceDetails']?['status'] ?? sr['status'] ?? 'pending';
          return status.toLowerCase() == statusFilter.toLowerCase();
        }).toList();
      }
      
      // Apply search filter if there's a search query
      if (_searchController.text.isNotEmpty) {
        _searchServiceRequests(_searchController.text);
      }
    });
  }

  String _getStatusFromFilter(String filter) {
    switch (filter) {
      case 'In Progress':
        return 'in_progress';
      case 'Pending':
        return 'pending';
      case 'Delayed':
        return 'delayed';
      case 'Completed':
        return 'completed';
      default:
        return 'pending';
    }
  }

  void _searchServiceRequests(String query) {
    setState(() {
      if (query.isEmpty) {
        _filterServiceRequests(_selectedFilter);
      } else {
        _filteredServiceRequests = _filteredServiceRequests.where((sr) {
          String srId = sr['serviceDetails']?['srId'] ?? sr['srId'] ?? '';
          String customerName = sr['customerDetails']?['name'] ?? '';
          String model = sr['equipmentDetails']?['model'] ?? '';
          
          return srId.toLowerCase().contains(query.toLowerCase()) ||
                 customerName.toLowerCase().contains(query.toLowerCase()) ||
                 model.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  String _getDisplayStatus(Map<String, dynamic> serviceRequest) {
    String status = serviceRequest['status'] ?? 'pending';
    switch (status.toLowerCase()) {
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'delayed':
        return 'Delayed';
      case 'pending':
        return 'Pending';
      default:
        return 'Pending';
    }
  }

  Color _getStatusColor(String status) {
    print('DEBUG: Getting color for status: $status');
    switch (status.toLowerCase()) {
      
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'delayed':
        return Colors.red;
      default:
        return Colors.grey;
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

  // Check if service request can be edited - FIXED VERSION
  bool _canEditServiceRequest(Map<String, dynamic> serviceRequest) {
    // Get status from both possible locations
    String status = serviceRequest['serviceDetails']?['status'] ?? serviceRequest['status'] ?? 'pending';
    
    // Debug print to see what status values we're getting
    print('DEBUG: Service Request Status: $status');
    
    // Allow editing for pending, in_progress, and delayed requests
    List<String> editableStatuses = ['pending', 'in_progress', 'delayed'];
    return editableStatuses.contains(status.toLowerCase());
  }

  // Show edit dialog
  void _showEditDialog(Map<String, dynamic> serviceRequest) {
    showDialog(
      context: context,
      builder: (context) => EditServiceRequestDialog(
        serviceRequest: serviceRequest,
        onUpdated: _loadServiceRequests, // Refresh the list after update
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: Normalappbar(
        title: 'Services',
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filterOptions.length,
              itemBuilder: (context, index) {
                String option = _filterOptions[index];
                bool isSelected = _selectedFilter == option;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      option,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        _filterServiceRequests(option);
                      }
                    },
                    selectedColor: Colors.blue,
                    backgroundColor: Colors.grey[200],
                  ),
                );
              },
            ),
          ),
          
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search service requests...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: _searchServiceRequests,
            ),
          ),
          
          // Service Requests List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredServiceRequests.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No service requests found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search or filter criteria',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadServiceRequests,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredServiceRequests.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> serviceRequest = _filteredServiceRequests[index];
                            
                            String srId = serviceRequest['serviceDetails']?['srId'] ?? serviceRequest['srId'] ?? 'N/A';
                            String customerName = serviceRequest['customerDetails']?['name'] ?? 'Unknown Customer';
                            String model = serviceRequest['equipmentDetails']?['model'] ?? 'Unknown Model';
                            String requestType = serviceRequest['serviceDetails']?['requestType'] ?? 'General Service';
                            String assignedDate = _formatDate(serviceRequest['serviceDetails']?['assignedDate'] ?? serviceRequest['createdAt']);
                            String status = _getDisplayStatus(serviceRequest);  
                            String serviceStatus =  serviceRequest['status'];
                            String assignedTo = serviceRequest['serviceDetails']?['assignedTechnician'] ?? 'Unassigned';
                            
                            bool canEdit = _canEditServiceRequest(serviceRequest);
                            
                            // Debug print to see the edit status
                            print('DEBUG: SR $srId - canEdit: $canEdit, status: ${serviceRequest['status']}, serviceDetails status: ${serviceRequest['serviceDetails']?['status']}');
                            
                            return Card(
                              color: Colors.grey.shade100,
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ServiceDetailsPage(
                                        serviceRequestId: srId,
                                      ),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Service Request ID, Status, and Edit Button
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              srId,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(status).withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: _getStatusColor(serviceStatus),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Text(
                                                  status,
                                                  style: TextStyle(
                                                    color: _getStatusColor(serviceStatus),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              // ALWAYS SHOW EDIT BUTTON FOR DEBUGGING
                                              const SizedBox(width: 8),
                                              InkWell(
                                                onTap: () => _showEditDialog(serviceRequest),
                                                child: Container(
                                                  padding: const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: canEdit 
                                                        ? Colors.blue.withOpacity(0.1)
                                                        : Colors.grey.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Icon(
                                                    Icons.edit,
                                                    size: 16,
                                                    color: canEdit ? Colors.blue : Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 8),
                                      
                                      // Customer and Model
                                      Text(
                                        '$customerName - $model',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 4),
                                      
                                      // Request Type
                                      Text(
                                        requestType.replaceAll('_', ' ').toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      

                                      Text(
                                            'Technician: $assignedTo',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),

                                      
                                      // Assigned Date
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.schedule,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                            
                                          Text(
                                            'Assigned: $assignedDate',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation( 
        currentIndex: 3, // 'Services' tab index
        onTap: (currentIndex) => BottomNavigation.navigateTo(currentIndex, context),
      ),
    );

  
  }
}