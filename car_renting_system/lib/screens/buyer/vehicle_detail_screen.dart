import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import 'booking_screen.dart';

class VehicleDetailScreen extends StatelessWidget {
  final String name;
  final String image;
  final double price;

  const VehicleDetailScreen({
    super.key,
    required this.name,
    required this.image,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          buildImageSection(context),
          buildDetailsSection(context),
          buildBackButton(context),
        ],
      ),
      bottomNavigationBar: Container(
  padding: const EdgeInsets.all(20),
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      minimumSize: const Size(double.infinity, 55),
    ),
    onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BookingScreen(
        vehicleName: name,
        pricePerDay: price,
      ),
    ),
  );
},
    child: const Text("Book Now"),
  ),
),
    );
  }

  Widget buildImageSection(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      width: double.infinity,
      child: Image.network(
        image,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget buildDetailsSection(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.55,
      maxChildSize: 0.9,
      builder: (context, controller) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: ListView(
            controller: controller,
            children: [
              buildTitleRow(),
              const SizedBox(height: 10),
              buildRatingRow(),
              const SizedBox(height: 20),
              const Text(
                "Features",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              buildFeaturesRow(),
              const SizedBox(height: 30),
              const Text(
                "Description",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              const Text(
                "Premium comfortable vehicle with modern features. Perfect for city drives and long trips.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  Widget buildTitleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          "\$$price/day",
          style: const TextStyle(
            fontSize: 20,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget buildRatingRow() {
    return Row(
      children: const [
        Icon(Icons.star, color: Colors.amber),
        SizedBox(width: 5),
        Text("4.8"),
        SizedBox(width: 10),
        Text("(120 reviews)", style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget buildFeaturesRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        FeatureIcon(icon: Icons.ac_unit, label: "AC"),
        FeatureIcon(icon: Icons.map, label: "GPS"),
        FeatureIcon(icon: Icons.bluetooth, label: "Bluetooth"),
        FeatureIcon(icon: Icons.settings, label: "Auto"),
      ],
    );
  }

  Widget buildBackButton(BuildContext context) {
    return Positioned(
      top: 40,
      left: 20,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back),
        ),
      ),
    );
  }
}

class FeatureIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const FeatureIcon({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xFF2A2A2E),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(height: 5),
        Text(label),
      ],
    );
  }
}