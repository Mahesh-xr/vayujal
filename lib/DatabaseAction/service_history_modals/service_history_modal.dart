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
      resolution: data['resolution'],
      partsReplaced: List<String>.from(data['partsReplaced'] ?? []),
      amcChecklist: data['amcChecklist'],
      technicianSuggestions: List<String>.from(data['technicianSuggestions'] ?? []),
      nextServiceDate: (data['nextServiceDate'] as Timestamp?)?.toDate(),
    );
  }
}

class AWGDetails {
  final String srNumber;
  final String type; // Premium, Standard
  final String coverage;
  final DateTime startDate;
  final DateTime endDate;

  AWGDetails({
    required this.srNumber,
    required this.type,
    required this.coverage,
    required this.startDate,
    required this.endDate,
  });

  factory AWGDetails.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AWGDetails(
      srNumber: data['srNumber'] ?? '',
      type: data['type'] ?? 'Standard',
      coverage: data['coverage'] ?? 'Service only, parts extra',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  bool get isExpired => DateTime.now().isAfter(endDate);
  String get status => isExpired ? 'Expired' : 'Active';
  String get dateRange => 
      '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}-'
      '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
}