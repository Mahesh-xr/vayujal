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
  
}