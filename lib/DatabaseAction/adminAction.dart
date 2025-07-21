// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class AdminAction {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============== EXISTING DEVICE MANAGEMENT METHODS ==============

  static Future<List<Map<String, dynamic>>> getAllTechnicians() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('technicians')
          .get();

      List<Map<String, dynamic>> technicians = snapshot.docs.map((doc) {
        return {
          'name': doc['fullName'] ?? '',
          'empId': doc['employeeId'] ?? '',
        };
      }).toList();

      return technicians;
    } catch (e) {
      print("🔥Error fetching technicians: $e");
      return [];
    }  
  }

  /// Adds a new device to Firestore
  static Future addNewDevice(Map<String, dynamic> deviceData) async {
    try {
      String serialNumber = deviceData['deviceInfo']['awgSerialNumber'];
      await _firestore.collection('devices').doc(serialNumber).set(deviceData);
      print("✅ Device added successfully: $serialNumber");
    } catch (e) {
      print("❌ Error adding device: $e");
    }
  }

  /// Updates an existing device in Firestore
  static Future editDevice(String serialNumber, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('devices').doc(serialNumber).update(updatedData);
      print("✅ Device updated successfully: $serialNumber");
    } catch (e) {
      print("❌ Error updating device: $e");
    }
  }

  /// Fetches all devices from Firestore
  static Future<List<Map<String, dynamic>>> getAllDevices() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('devices').get();
      List<Map<String, dynamic>> devices = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      print("✅ Fetched ${devices.length} devices.");
      return devices;
    } catch (e) {
      print("❌ Error fetching devices: $e");
      return [];
    }
  }

  /// Fetch a single device by its serial number
  static Future<Map<String, dynamic>?> getDeviceBySerial(String serialNumber) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('devices').doc(serialNumber).get();
      if (doc.exists) {
        print("✅ Device found: $serialNumber");
        return doc.data() as Map<String, dynamic>;
      } else {
        print("⚠️ No device found with serial: $serialNumber");
        return null;
      }
    } catch (e) {
      print("❌ Error fetching device: $e");
      return null;
    }
  }

  /// Fetch unique cities from all devices
  static Future<List<String>> getUniqueCities() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('devices').get();
      Set<String> cities = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final locationDetails = data['locationDetails'] as Map<String, dynamic>?;
        final city = locationDetails?['city']?.toString().trim();
        
        if (city != null && city.isNotEmpty) {
          cities.add(city);
        }
      }
      
      List<String> sortedCities = cities.toList()..sort();
      print("✅ Fetched ${sortedCities.length} unique cities.");
      return sortedCities;
    } catch (e) {
      print("❌ Error fetching cities: $e");
      return [];
    }
  }

  /// Fetch unique states from all devices
  static Future<List<String>> getUniqueStates() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('devices').get();
      Set<String> states = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final locationDetails = data['locationDetails'] as Map<String, dynamic>?;
        final state = locationDetails?['state']?.toString().trim();
        
        if (state != null && state.isNotEmpty) {
          states.add(state);
        }
      }
      
      List<String> sortedStates = states.toList()..sort();
      print("✅ Fetched ${sortedStates.length} unique states.");
      return sortedStates;
    } catch (e) {
      print("❌ Error fetching states: $e");
      return [];
    }
  }

  /// Fetch unique models from all devices
  static Future<List<String>> getUniqueModels() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('devices').get();
      Set<String> models = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final deviceInfo = data['deviceInfo'] as Map<String, dynamic>?;
        final model = deviceInfo?['model']?.toString().trim();
        
        if (model != null && model.isNotEmpty) {
          models.add(model);
        }
      }
      
      List<String> sortedModels = models.toList()..sort();
      print("✅ Fetched ${sortedModels.length} unique models.");
      return sortedModels;
    } catch (e) {
      print("❌ Error fetching models: $e");
      return [];
    }
  }

  /// Fetch devices with multiple filters
  static Future<List<Map<String, dynamic>>> getFilteredDevices({
    List<String>? models,
    List<String>? cities,
    List<String>? states,
    String? searchTerm,
  }) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('devices').get();
      List<Map<String, dynamic>> devices = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      
      // Apply filters
      List<Map<String, dynamic>> filteredDevices = devices.where((device) {
        final deviceInfo = device['deviceInfo'] as Map<String, dynamic>?;
        final locationDetails = device['locationDetails'] as Map<String, dynamic>?;
        final customerDetails = device['customerDetails'] as Map<String, dynamic>?;
        
        // Model filter
        if (models != null && models.isNotEmpty) {
          final deviceModel = deviceInfo?['model']?.toString();
          if (deviceModel == null || !models.contains(deviceModel)) {
            return false;
          }
        }
        
        // City filter
        if (cities != null && cities.isNotEmpty) {
          final deviceCity = locationDetails?['city']?.toString();
          if (deviceCity == null || !cities.contains(deviceCity)) {
            return false;
          }
        }
        
        // State filter
        if (states != null && states.isNotEmpty) {
          final deviceState = locationDetails?['state']?.toString();
          if (deviceState == null || !states.contains(deviceState)) {
            return false;
          }
        }
        
        // Search term filter
        if (searchTerm != null && searchTerm.isNotEmpty) {
          final searchLower = searchTerm.toLowerCase();
          final model = deviceInfo?['model']?.toString().toLowerCase() ?? '';
          final serialNumber = deviceInfo?['serialNumber']?.toString().toLowerCase() ?? '';
          final company = customerDetails?['company']?.toString().toLowerCase() ?? '';
          final city = locationDetails?['city']?.toString().toLowerCase() ?? '';
          
          if (!model.contains(searchLower) && 
              !serialNumber.contains(searchLower) && 
              !company.contains(searchLower) && 
              !city.contains(searchLower)) {
            return false;
          }
        }
        
        return true;
      }).toList();
      
      print("✅ Filtered ${filteredDevices.length} devices from ${devices.length} total devices.");
      return filteredDevices;
    } catch (e) {
      print("❌ Error fetching filtered devices: $e");
      return [];
    }
  }

  /// Get devices count by filter criteria
  static Future<Map<String, int>> getDevicesCountByFilters() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('devices').get();
      List<Map<String, dynamic>> devices = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      
      Map<String, int> modelCounts = {};
      Map<String, int> cityCounts = {};
      Map<String, int> stateCounts = {};
      
      for (var device in devices) {
        final deviceInfo = device['deviceInfo'] as Map<String, dynamic>?;
        final locationDetails = device['locationDetails'] as Map<String, dynamic>?;
        
        // Count models
        final model = deviceInfo?['model']?.toString();
        if (model != null && model.isNotEmpty) {
          modelCounts[model] = (modelCounts[model] ?? 0) + 1;
        }
        
        // Count cities
        final city = locationDetails?['city']?.toString();
        if (city != null && city.isNotEmpty) {
          cityCounts[city] = (cityCounts[city] ?? 0) + 1;
        }
        
        // Count states
        final state = locationDetails?['state']?.toString();
        if (state != null && state.isNotEmpty) {
          stateCounts[state] = (stateCounts[state] ?? 0) + 1;
        }
      }
      
      return {
        'models': modelCounts.length,
        'cities': cityCounts.length,
        'states': stateCounts.length,
        'totalDevices': devices.length,
      };
    } catch (e) {
      print("❌ Error getting devices count: $e");
      return {};
    }
  }

  /// Delete a device from Firestore
  static Future<bool> deleteDevice(String serialNumber) async {
    try {
      await _firestore.collection('devices').doc(serialNumber).delete();
      print("✅ Device deleted successfully: $serialNumber");
      return true;
    } catch (e) {
      print("❌ Error deleting device: $e");
      return false;
    }
  }

  /// Check if device exists before deletion
  static Future<bool> deviceExists(String serialNumber) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('devices').doc(serialNumber).get();
      return doc.exists;
    } catch (e) {
      print("❌ Error checking device existence: $e");
      return false;
    }
  }

  // ============== NEW SERVICE REQUEST MANAGEMENT METHODS ==============

  /// Generate unique Service Request ID
  static String _generateServiceRequestId() {
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String random = Random().nextInt(999).toString().padLeft(3, '0');
    return 'SR_${timestamp.substring(8)}_$random';
  }

  /// Create a new service request
  static Future<String> createServiceRequest({
    required Map<String, dynamic> equipmentDetails,
    required Map<String, dynamic> customerDetails,
    required Map<String, dynamic> serviceDetails,
    String? deviceId,
  }) async {
    try {
      // Generate unique SR ID
      String srId = _generateServiceRequestId();
      
      // Prepare service request data
      Map<String, dynamic> serviceRequestData = {
        'srId': srId,
        'deviceId': deviceId,
        'equipmentDetails': equipmentDetails,
        'customerDetails': customerDetails,
        'serviceDetails': {
          ...serviceDetails,
          'createdDate': FieldValue.serverTimestamp(),
        },
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Save to Firestore
      await _firestore.collection('serviceRequests').doc(srId).set(serviceRequestData);
      
      print("✅ Service request created successfully: $srId");
      return srId;
    } catch (e) {
      print("❌ Error creating service request: $e");
      throw Exception('Failed to create service request: $e');
    }
  }

  /// Get all service requests
  static Future<List<Map<String, dynamic>>> getAllServiceRequests() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('serviceRequests')
          .orderBy('createdAt', descending: true)
          .get();
      
      List<Map<String, dynamic>> serviceRequests = snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
      
      print("✅ Fetched ${serviceRequests.length} service requests.");
      return serviceRequests;
    } catch (e) {
      print("❌ Error fetching service requests: $e");
      return [];
    }
  }

  /// Get service requests by status
  static Future<List<Map<String, dynamic>>> getServiceRequestsByStatus(String status) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('serviceRequests')
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();
      
      List<Map<String, dynamic>> serviceRequests = snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
      
      print("✅ Fetched ${serviceRequests.length} service requests with status: $status");
      return serviceRequests;
    } catch (e) {
      print("❌ Error fetching service requests by status: $e");
      return [];
    }
  }

  /// Get available technicians for assignment
  static Future<List<Map<String, dynamic>>> getAvailableTechnicians() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('technicians')
          .get();
      
      List<Map<String, dynamic>> technicians = snapshot.docs.map((doc) => {
        'empId': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
      
      print("✅ Fetched ${technicians.length} available technicians.");
      return technicians;
    } catch (e) {
      print("❌ Error fetching available technicians: $e");
      return [];
    }
  }

  /// Get service request by ID
  static Future<Map<String, dynamic>?> getServiceRequestById(String serviceRequestId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('serviceRequests')
          .doc(serviceRequestId)
          .get();
      
      if (doc.exists) {
        print("✅ Service request found: $serviceRequestId");
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      } else {
        print("⚠️ No service request found with ID: $serviceRequestId");
        return null;
      }
    } catch (e) {
      print("❌ Error fetching service request: $e");
      return null;
    }
  }
  

   static Future<bool> updateServiceRequest({
    required String srId,
    String? newAssignedTo,
    String? status,
    String? comments,
    DateTime? newAddressByDate,
    String? requestType,
    String? assignedTechnician,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Update service details if provided
      if (newAssignedTo != null) {
        updateData['serviceDetails.assignedTo'] = newAssignedTo;
        updateData['serviceDetails.reassignedAt'] = FieldValue.serverTimestamp();
      }
      
      if (status != null) {
        updateData['status'] = status;
      }

      if (comments != null) {
        updateData['serviceDetails.comments'] = comments;
      }

      if (newAddressByDate != null) {
        updateData['serviceDetails.addressByDate'] = Timestamp.fromDate(newAddressByDate);
      }

      if (requestType != null) {
        updateData['serviceDetails.requestType'] = requestType;
      }
        if (requestType != null) {
        updateData['serviceDetails.assignedTechnician'] = assignedTechnician;
      }

      // Update the document
      await _firestore.collection('serviceRequests').doc(srId).update(updateData);
      
      // Create notification for the newly assigned technician
      if (newAssignedTo != null) {
        await _createAssignmentNotification(srId, newAssignedTo, isReassignment: true);
      }

      print("✅ Service request updated successfully: $srId");
      return true;
    } catch (e) {
      print("❌ Error updating service request: $e");
      throw Exception('Failed to update service request: $e');
    }
  }

  /// Create notification for technician assignment
  static Future<void> _createAssignmentNotification(
    String srId, 
    String technicianEmpId, 
    {bool isReassignment = false}
  ) async {
    try {
      // Get technician details
      QuerySnapshot techQuery = await _firestore
          .collection('technicians')
          .where('employeeId', isEqualTo: technicianEmpId)
          .limit(1)
          .get();

      if (techQuery.docs.isNotEmpty) {
        String technicianUid = techQuery.docs.first.id;
        
        // Create notification document
        await _firestore.collection('notifications').add({
          'userId': technicianUid,
          'userType': 'technician',
          'title': isReassignment 
              ? 'Service Request Reassigned'
              : 'New Service Request Assigned',
          'message': isReassignment 
              ? 'You have been reassigned to service request: $srId'
              : 'You have been assigned a new service request: $srId',
          'type': 'service_assignment',
          'serviceRequestId': srId,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });

        print("✅ Notification created for technician: $technicianEmpId");
      }
    } catch (e) {
      print("❌ Error creating notification: $e");
    }
  }

  /// Get notifications for a user
  static Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print("❌ Error getting notifications: $e");
      return [];
    }
  }

  /// Mark notification as read
  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("❌ Error marking notification as read: $e");
    }
  }

  /// Get unread notification count
  static Future<int> getUnreadNotificationCount(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print("❌ Error getting unread notification count: $e");
      return 0;
    }
  }

  /// Update the existing createServiceRequest method to include notification
  /// 
  /// 
  /// 
   static Future<Map<String, dynamic>?> getServiceHistoryBySrId(String srId) async {
    try {
      // Query the serviceHistory collection using srId as document ID
      DocumentSnapshot doc = await _firestore
          .collection('serviceHistory')
          .doc(srId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        // Add document ID to the data for reference
        data['id'] = doc.id;
        
        return data;
      } else {
        // Document doesn't exist
        return null;
      }
    } catch (e) {
      print('Error fetching service history for SR ID $srId: $e');
      throw Exception('Failed to fetch service history: $e');
    }
  }

  /// Alternative method if you're using srNumber field instead of document ID
  /// Get service history by SR Number field
  static Future<Map<String, dynamic>?> getServiceHistoryBySrNumber(String srNumber) async {
    try {
      // Query the serviceHistory collection using srNumber field
      QuerySnapshot querySnapshot = await _firestore
          .collection('serviceHistory')
          .where('srNumber', isEqualTo: srNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = querySnapshot.docs.first;
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        // Add document ID to the data for reference
        data['id'] = doc.id;
        
        return data;
      } else {
        // No document found with this srNumber
        return null;
      }
    } catch (e) {
      print('Error fetching service history for SR Number $srNumber: $e');
      throw Exception('Failed to fetch service history: $e');
    }
  }

  /// Get all service history records for a specific AWG serial number
  /// Useful for viewing complete service history of a device
  static Future<List<Map<String, dynamic>>> getServiceHistoryByAwgSerial(String awgSerialNumber) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('serviceHistory')
          .where('awgSerialNumber', isEqualTo: awgSerialNumber)
          .orderBy('timestamp', descending: true)
          .get();

      List<Map<String, dynamic>> serviceHistoryList = [];
      
      for (DocumentSnapshot doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        serviceHistoryList.add(data);
      }

      return serviceHistoryList;
    } catch (e) {
      print('Error fetching service history for AWG Serial $awgSerialNumber: $e');
      throw Exception('Failed to fetch service history: $e');
    }
  }

  /// Get service history with pagination
  /// Useful for loading large datasets efficiently
  static Future<List<Map<String, dynamic>>> getServiceHistoryPaginated({
    int limit = 20,
    DocumentSnapshot? startAfter,
    String? status,
    String? technician,
  }) async {
    try {
      Query query = _firestore
          .collection('serviceHistory')
          .orderBy('timestamp', descending: true);

      // Add filters if provided
      if (status != null && status.isNotEmpty) {
        query = query.where('status', isEqualTo: status);
      }
      
      if (technician != null && technician.isNotEmpty) {
        query = query.where('technician', isEqualTo: technician);
      }

      // Add pagination
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      query = query.limit(limit);

      QuerySnapshot querySnapshot = await query.get();
      
      List<Map<String, dynamic>> serviceHistoryList = [];
      
      for (DocumentSnapshot doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        serviceHistoryList.add(data);
      }

      return serviceHistoryList;
    } catch (e) {
      print('Error fetching paginated service history: $e');
      throw Exception('Failed to fetch service history: $e');
    }
  }

  /// Get service statistics
  /// Returns counts and analytics for service history
  static Future<Map<String, dynamic>> getServiceHistoryStats() async {
    try {
      // Get all service history records
      QuerySnapshot allDocs = await _firestore
          .collection('serviceHistory')
          .get();

      Map<String, int> statusCounts = {};
      Map<String, int> technicianCounts = {};
      Map<String, int> issueTypeCounts = {};
      int totalServices = allDocs.docs.length;

      for (DocumentSnapshot doc in allDocs.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        // Count by status
        String status = data['status'] ?? 'unknown';
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
        
        // Count by technician
        String technician = data['technician'] ?? 'unknown';
        technicianCounts[technician] = (technicianCounts[technician] ?? 0) + 1;
        
        // Count by issue type
        String issueType = data['issueType'] ?? 'unknown';
        issueTypeCounts[issueType] = (issueTypeCounts[issueType] ?? 0) + 1;
      }

      return {
        'totalServices': totalServices,
        'statusCounts': statusCounts,
        'technicianCounts': technicianCounts,
        'issueTypeCounts': issueTypeCounts,
      };
    } catch (e) {
      print('Error fetching service history stats: $e');
      throw Exception('Failed to fetch service history statistics: $e');
    }
  }

  /// Update service history record
  /// Used for updating existing service records
  static Future<bool> updateServiceHistory(String srId, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection('serviceHistory')
          .doc(srId)
          .update(updates);
      
      return true;
    } catch (e) {
      print('Error updating service history for SR ID $srId: $e');
      throw Exception('Failed to update service history: $e');
    }
  }

  /// Delete service history record
  /// Used for removing service records (use with caution)
  static Future<bool> deleteServiceHistory(String srId) async {
    try {
      await _firestore
          .collection('serviceHistory')
          .doc(srId)
          .delete();
      
      return true;
    } catch (e) {
      print('Error deleting service history for SR ID $srId: $e');
      throw Exception('Failed to delete service history: $e');
    }
  }

  /// Create new service history record
  /// Used when a service is completed
  static Future<bool> createServiceHistory(String srId, Map<String, dynamic> serviceData) async {
    try {
      await _firestore
          .collection('serviceHistory')
          .doc(srId)
          .set(serviceData);
      
      return true;
    } catch (e) {
      print('Error creating service history for SR ID $srId: $e');
      throw Exception('Failed to create service history: $e');
    }
  } 
}