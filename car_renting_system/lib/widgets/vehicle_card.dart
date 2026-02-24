import 'package:flutter/material.dart';
import '../core/theme/colors.dart';
import '../screens/buyer/vehicle_detail_screen.dart';

class VehicleCard extends StatelessWidget {
  final String name;
  final String image;
  final double price;

  const VehicleCard({
    super.key,
    required this.name,
    required this.image,
    required this.price,
  });

  @override
Widget build(BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VehicleDetailScreen(
            name: name,
            image: image,
            price: price,
          ),
        ),
      );
    },
    child: Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(
              image,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 100,
                color: Colors.grey[800],
                child: const Icon(Icons.directions_car, size: 40),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "\$$price/day",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
  }
