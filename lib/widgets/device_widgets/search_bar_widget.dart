// widgets/search_bar_widget.dart
import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const SearchBarWidget({
    Key? key,
    this.hintText = 'Search Devices',
    this.controller,
    this.onChanged,
    this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: Colors.grey.shade600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}