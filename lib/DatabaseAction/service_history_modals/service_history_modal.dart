import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceHistoryItem {
  final String srNumber;
  final String serviceType;
  final String technician;
  final DateTime serviceDate;
  final String? issues;
  final String? resolution;
  final List<String>? partsReplaced;
  final Map<String, dynamic>? amcChecklist;
  final List<String>? technicianSuggestions;
  final DateTime? nextServiceDate;

  ServiceHistoryItem({
    required this.srNumber,
    required this.serviceType,
    required this.technician,
    required this.serviceDate,
    this.issues,
    this.resolution,
    this.partsReplaced,
    this.amcChecklist,
    this.technicianSuggestions,
    this.nextServiceDate,
  });

  factory ServiceHistoryItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ServiceHistoryItem(
      srNumber: data['srNumber'] ?? '',
      serviceType: data['serviceType'] ?? 'General Service',
      technician: data['technician'] ?? 'Name',
      serviceDate: (data['serviceDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      issues: data['issues'],
      resolution: data['resolutions'],
      // partsReplaced: List<String>.from(data['partsReplaced'] ?? []),
      // amcChecklist: data['amcChecklist'],
      // technicianSuggestions: List<String>.from(data['technicianSuggestions'] ?? []),
      nextServiceDate: (data['nextServiceDate'] as Timestamp?)?.toDate(),
    );
  }
}

class AWGDetails {
  final String srNumber;
  final String type; // Premium, Standard
  final DateTime startDate;
  final DateTime endDate;

  AWGDetails({
    required this.srNumber,
    required this.type,
    required this.startDate,
    required this.endDate,
  });

  factory AWGDetails.fromFirestore(DocumentSnapshot doc) {
  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  
  // Get maintenanceContract data if it exists
  Map<String, dynamic>? maintenanceContract = data['maintenanceContract'];
  
  return AWGDetails(
    srNumber: data['serialNumber']?.toString() ?? '', // Use serialNumber from root
    type: maintenanceContract?['amcType'] ?? 'Standard', // Get from maintenanceContract
    startDate: _parseDate(maintenanceContract?['amcStartDate']) ?? DateTime.now(),
    endDate: _parseDate(maintenanceContract?['amcEndDate']) ?? DateTime.now(),
  );
}

// Helper method to parse date strings
static DateTime? _parseDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) return null;
  
  try {
    // Parse date in format "5/6/2025" or "26/6/2025"
    List<String> parts = dateString.split('/');
    if (parts.length == 3) {
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);
      return DateTime(year, month, day);
    }
  } catch (e) {
    print('Error parsing date: $dateString, error: $e');
  }
  
  return null;
}

  bool get isExpired => DateTime.now().isAfter(endDate);
  String get status => isExpired ? 'Expired' : 'Active';
  String get dateRange => 
      '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}-'
      '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
}