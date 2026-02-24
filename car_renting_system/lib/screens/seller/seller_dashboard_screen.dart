import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Seller Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            buildStatCard("Total Earnings", "\$1200"),
            const SizedBox(height: 20),
            buildStatCard("Total Bookings", "25"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}