import 'package:flutter/material.dart';
import 'package:vayujal/DatabaseAction/service_history_modals/service_history_modal.dart';

class AMCHistoryCard extends StatelessWidget {
  final AWGDetails awg;

  const AMCHistoryCard({Key? key, required this.awg}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SR Number:  ${awg.srNumber}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: awg.isExpired ? Colors.red[100] : Colors.green[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    awg.status,
                    style: TextStyle(
                      color: awg.isExpired ? Colors.red[800] : Colors.green[800],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(awg.dateRange),
            const SizedBox(height: 4),
            Text('Type: ${awg.type}'),
           
          ],
        ),
      ),
    );
  }
}