import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vayujal/DatabaseAction/service_history_modals/service_history_modal.dart';

class ServiceHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all service history for a specific serial number
  Future<List<ServiceHistoryItem>> getServiceHistory(String serialNumber) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('service_history')
          .where('srNumber', isEqualTo: serialNumber)
          // .orderBy('serviceDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ServiceHistoryItem.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching service history: $e');
      return [];
    }
  }

  // Get AWG details for a specific serial number
  Future<List<AWGDetails>> getAWGDetails(String serialNumber) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('devices')
          .where('deviceId', isEqualTo: serialNumber)
          .get();
    

      return querySnapshot.docs
          .map((doc) => AWGDetails.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching AWG details  bro: $e');
      return [];
    }
  }

  // Check AWG status based on current date
  Future<Map<String, dynamic>> checkAWGStatus(String serialNumber) async {
    try {
      List<AWGDetails> awgDetails = await getAWGDetails(serialNumber);
      
      if (awgDetails.isEmpty) {
        return {'hasAWG': false, 'status': 'No AWG'};
      }

      // Find current active AWG
      AWGDetails? activeAWG = awgDetails.where((awg) => !awg.isExpired).isNotEmpty
          ? awgDetails.where((awg) => !awg.isExpired).first
          : null;

      return {
        'hasAWG': true,
        'activeAWG': activeAWG,
        'allAWG': awgDetails,
        'status': activeAWG != null ? 'Active' : 'Expired',
      };
    } catch (e) {
      print('Error checking AWG status: $e');
      return {'hasAWG': false, 'status': 'Error'};
    }
  }
}