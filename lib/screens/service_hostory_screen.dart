import 'package:flutter/material.dart';
import 'package:vayujal/DatabaseAction/service_history_modals/service_history_modal.dart';
import 'package:vayujal/screens/service_details_screen.dart';
import 'package:vayujal/services/service_history_services.dart';
import 'package:vayujal/widgets/history/amc_history_card.dart';
import 'package:vayujal/widgets/history/service_history_card.dart';
import 'package:vayujal/widgets/navigations/custom_app_bar.dart';

class ServiceHistoryScreen extends StatefulWidget {
  final String serialNumber;

  const ServiceHistoryScreen({super.key, required this.serialNumber});

  @override
  // ignore: library_private_types_in_public_api
  _ServiceHistoryScreenState createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ServiceHistoryService _service = ServiceHistoryService();
  
  List<ServiceHistoryItem> serviceHistory = [];
  List<AWGDetails> awgHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    
    try {
      final serviceData = await _service.getServiceHistory(widget.serialNumber);
      final awgData = await _service.getAWGDetails(widget.serialNumber);
      
      
      setState(() {
        serviceHistory = serviceData;
        awgHistory = awgData;
        print("DATAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
        print(serviceHistory);
        print(awgHistory);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(title: "Service History"),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Service History'),
                Tab(text: 'AMC History'),
              ],
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
            ),
          ),
          // Tab Views
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildServiceHistoryTab(),
                      _buildAMCHistoryTab(),
                    ],
                  ),
          ),
        ],
      ),
     
    );
  }

  Widget _buildServiceHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: serviceHistory.length,
      itemBuilder: (context, index) {
        final service = serviceHistory[index];
        return ServiceHistoryCard(
          service: service,
          onTap: () => _showServiceDetails(service),
        );
      },
    );
  }

  Widget _buildAMCHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: awgHistory.length,
      itemBuilder: (context, index) {
        final awg = awgHistory[index];
        return AMCHistoryCard(awg: awg);
      },
    );
  }

  void _showServiceDetails(ServiceHistoryItem service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailScreen(service: service),
      ),
    );
  }

 

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}