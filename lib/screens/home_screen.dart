import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const greenColor = Color(0xFF0F6E2D);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenColor,
        elevation: 0,
      ),

      body: Stack(
        children: [
          Container(color: greenColor),

          Column(
            children: [
              const SizedBox(height: 70), 
              Expanded(
                child: Container(
                  color: Colors.grey.shade100,
                  child: const Center(
                    child: Text(
                      'Home Screen',
                      style: TextStyle(fontSize: 20, color: Colors.black87),
                    ),
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            top: 0, 
            left: 16,
            right: 16,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: Icon(Icons.search, color: greenColor),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
