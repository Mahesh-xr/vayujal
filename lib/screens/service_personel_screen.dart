import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vayujal/widgets/navigations/bottom_navigation.dart';
import 'package:vayujal/widgets/navigations/custom_app_bar.dart';

class ServicePersonnelPage extends StatefulWidget {
  @override
  _ServicePersonnelPageState createState() => _ServicePersonnelPageState();
}

class _ServicePersonnelPageState extends State<ServicePersonnelPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Delete technician
  Future<void> _deleteTechnician(String technicianId) async {
    try {
      await _firestore.collection('technicians').doc(technicianId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Technician deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting technician: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Show delete confirmation dialog
  void _showDeleteDialog(String technicianId, String technicianName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Technician'),
          content: Text('Are you sure you want to delete $technicianName?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTechnician(technicianId);
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Show technician details
  void _showTechnicianDetails(DocumentSnapshot technician) {
    final data = technician.data() as Map<String, dynamic>;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Technician Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Name', data['fullName'] ?? 'N/A'),
                _buildDetailRow('Designation', data['designation'] ?? 'N/A'),
                _buildDetailRow('Email', data['email'] ?? 'N/A'),
                _buildDetailRow('Mobile', data['mobileNumber'] ?? 'N/A'),
                _buildDetailRow('Employee ID', data['employeeId'] ?? 'N/A'),
                _buildDetailRow('UID', data['uid'] ?? 'N/A'),
                _buildDetailRow('Profile Complete', 
                  data['isProfileComplete'] == true ? 'Yes' : 'No'),
                _buildDetailRow('Created At', 
                  data['createdAt'] != null 
                    ? DateTime.fromMillisecondsSinceEpoch(
                        data['createdAt'].millisecondsSinceEpoch)
                        .toString()
                    : 'N/A'),
                _buildDetailRow('Updated At', 
                  data['updatedAt'] != null 
                    ? DateTime.fromMillisecondsSinceEpoch(
                        data['updatedAt'].millisecondsSinceEpoch)
                        .toString()
                    : 'N/A'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(title: "Personnel"),
      body: Column(
        children: [
          // Header Section
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Service Personnel',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Admin access',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search personnel.....',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Personnel List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('technicians').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final technicians = snapshot.data?.docs ?? [];
                
                // Filter technicians based on search query
                final filteredTechnicians = technicians.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['fullName'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery);
                }).toList();

                if (filteredTechnicians.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty 
                            ? 'No technicians found'
                            : 'No technicians match your search',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: filteredTechnicians.length,
                  itemBuilder: (context, index) {
                    final technician = filteredTechnicians[index];
                    final data = technician.data() as Map<String, dynamic>;
                    
                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: data['profileImageUrl'] != null && 
                              data['profileImageUrl'] != 'sample'
                              ? 
                              // NetworkImage(data['profileImageUrl'])
                              NetworkImage(data['profileImageUrl'])

                              : null,
                            child: data['profileImageUrl'] == null || 
                              data['profileImageUrl'] == 'sample'
                              ? Icon(Icons.person, color: Colors.grey[600])
                              : null,
                          ),
                          SizedBox(width: 16),
                          
                          // Technician Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['fullName'] ?? 'Unknown',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  data['designation'] ?? 'HVAC',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'available',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      '2 jobs', // You can make this dynamic based on actual jobs
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
                          
                          // Action Buttons
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // View Button
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: TextButton(
                                  onPressed: () => _showTechnicianDetails(technician),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    minimumSize: Size(0, 0),
                                  ),
                                  child: Text(
                                    'View',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              
                              // Delete Button
                              GestureDetector(
                                onTap: () => _showDeleteDialog(
                                  technician.id,
                                  data['fullName'] ?? 'Unknown',
                                ),
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
        bottomNavigationBar: BottomNavigation(
      currentIndex: 2, // 'Devices' tab index
      onTap:(currentIndex) => BottomNavigation.navigateTo(currentIndex, context) ,
),
    );
  }
}