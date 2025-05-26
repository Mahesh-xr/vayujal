import 'package:flutter/material.dart';
import 'package:vayujal/widgets/dashboard/quick_actions_section.dart';
import 'package:vayujal/widgets/dashboard/status_cards_grid.dart';
import 'package:vayujal/widgets/navigations/bottom_navigation.dart';

import '../widgets/navigations/custom_app_bar.dart' show CustomAppBar;

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[80],
      appBar: const CustomAppBar(title: 'Dashboard'),
      body: _buildMainContent(),
      bottomNavigationBar: BottomNavigation(
      currentIndex: 0, // 'Devices' tab index
      onTap: (index) {
    

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/alldevice');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/history');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/notifications');
        break;
    }
  },
),

    );
  }

  Widget _buildMainContent() {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusCardsGrid(),
          SizedBox(height: 32),
          QuickActionsSection(),
        ],
      ),
    );
  }
}