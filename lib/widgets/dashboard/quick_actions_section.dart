import 'package:flutter/material.dart';
import 'package:vayujal/screens/add_device_screen.dart';
import 'action_button.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AddDeviceScreen()),
        );
          },
          child: ActionButton(
            title: 'Register new AWG', 
            icon: Icons.add_circle,
          ),
        ),
        const SizedBox(height: 12),
        const ActionButton(
          title: 'View all Tasks', 
          icon: Icons.task_alt,
        ),
        const SizedBox(height: 12),
        const ActionButton(
          title: 'View all Devices', 
          icon: Icons.devices,
        ),
      ],
    );
  }
}