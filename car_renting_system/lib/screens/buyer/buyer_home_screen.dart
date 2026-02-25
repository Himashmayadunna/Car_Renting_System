import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/vehicle_card.dart';

class BuyerHomeScreen extends StatelessWidget {
  const BuyerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hello, ${user?.name.split(' ').first ?? 'there'} 👋",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Find your perfect ride",
                            style: TextStyle(color: AppColors.textGrey),
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.cardDark,
                      child: Icon(Icons.notifications_outlined,
                          color: AppColors.textGrey),
                    ),
                  ],
                ),
              ),
            ),

            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: AppColors.textGrey),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Search vehicles...",
                            border: InputBorder.none,
                            fillColor: Colors.transparent,
                            filled: true,
                          ),
                        ),
                      ),
                      Icon(Icons.tune, color: AppColors.textGrey),
                    ],
                  ),
                ),
              ),
            ),

            // Vehicle type tabs
            SliverToBoxAdapter(
              child: Consumer<VehicleProvider>(
                builder: (context, vehicleProvider, _) {
                  final types = ['All', 'Standard', 'Comfort', 'Business'];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
                    child: SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: types.length,
                        itemBuilder: (context, index) {
                          final type = types[index];
                          final isSelected =
                              vehicleProvider.selectedType == type;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () => vehicleProvider.setType(type),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.cardDark,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    type,
                                    style: TextStyle(
                                      color: isSelected
                                          ? AppColors.textDark
                                          : AppColors.textGrey,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // Section title
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Available Vehicles",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "See all",
                      style: TextStyle(color: AppColors.primary, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            // Vehicle grid
            Consumer<VehicleProvider>(
              builder: (context, vehicleProvider, _) {
                final vehicles = vehicleProvider.vehicles;

                if (vehicles.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.directions_car_outlined,
                                size: 64, color: AppColors.textGrey),
                            SizedBox(height: 16),
                            Text(
                              "No vehicles available yet",
                              style: TextStyle(color: AppColors.textGrey),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Check back later for new listings",
                              style: TextStyle(
                                  color: AppColors.textGrey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final vehicle = vehicles[index];
                        return VehicleCard(vehicle: vehicle);
                      },
                      childCount: vehicles.length,
                    ),
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}