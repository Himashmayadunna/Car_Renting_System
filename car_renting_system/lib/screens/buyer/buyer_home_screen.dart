import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../widgets/vehicle_card.dart';

class BuyerHomeScreen extends StatelessWidget {
  const BuyerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: AppColors.cardDark,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    "Map coming soon",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          buildBottomSheet(),
        ],
      ),
    );
  }

  Widget buildBottomSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.2,
      maxChildSize: 0.8,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                "Available Vehicles",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 170,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    VehicleCard(
                      name: "Toyota Corolla",
                      image:
                          "https://cdn.pixabay.com/photo/2012/05/29/00/43/car-49278_1280.jpg",
                      price: 40,
                    ),
                    VehicleCard(
                      name: "BMW X5",
                      image:
                          "https://cdn.pixabay.com/photo/2012/05/29/00/43/car-49278_1280.jpg",
                      price: 80,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}