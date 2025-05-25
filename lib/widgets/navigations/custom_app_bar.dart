import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  
  const CustomAppBar({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Image.asset(
            // 'assets/images/ayujal_logo.png', 
            //// Add your logo asset
            "assets/images/ayujal_logo.png",
            width: 80,
            height: 30,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}