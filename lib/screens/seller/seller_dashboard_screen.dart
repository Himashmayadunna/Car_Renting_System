import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../models/vehicle_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/booking_provider.dart';
import 'add_vehicle_screen.dart';

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return Text(
                  "Hello, ${auth.user?.name ?? 'Seller'}!",
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                );
              },
            ),
            const SizedBox(height: 4),
            const Text("Manage your vehicles and bookings",
                style: TextStyle(color: AppColors.textGrey)),
            const SizedBox(height: 24),

            // Stats row
            _buildStatsRow(context),
            const SizedBox(height: 28),

            // My vehicles header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("My Vehicles",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AddVehicleScreen()),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Add New"),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Vehicle list
            _buildVehicleList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textDark,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Consumer2<VehicleProvider, BookingProvider>(
      builder: (context, vehicleProv, bookingProv, _) {
        final vehicles = vehicleProv.sellerVehicles;
        final bookings = bookingProv.sellerBookings;
        final activeBookings =
            bookings.where((b) => b.status == 'active').length;
        final totalEarnings = bookings
            .where((b) => b.status == 'completed')
            .fold<double>(0, (sum, b) => sum + b.totalPrice);

        return Row(
          children: [
            Expanded(
              child: _statCard(
                Icons.directions_car,
                "${vehicles.length}",
                "Vehicles",
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                Icons.receipt_long,
                "$activeBookings",
                "Active",
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                Icons.attach_money,
                "\$${totalEarnings.toStringAsFixed(0)}",
                "Earnings",
                AppColors.success,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _statCard(
      IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildVehicleList() {
    return Consumer<VehicleProvider>(
      builder: (context, vehicleProv, _) {
        final vehicles = vehicleProv.sellerVehicles;

        if (vehicles.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.directions_car_outlined,
                      size: 60, color: AppColors.textGrey.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  const Text("No vehicles yet",
                      style: TextStyle(color: AppColors.textGrey)),
                  const SizedBox(height: 8),
                  const Text("Tap + to add your first vehicle",
                      style:
                          TextStyle(color: AppColors.textGrey, fontSize: 12)),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: vehicles.length,
          itemBuilder: (context, index) =>
              _SellerVehicleCard(vehicle: vehicles[index]),
        );
      },
    );
  }
}

class _SellerVehicleCard extends StatelessWidget {
  final VehicleModel vehicle;
  const _SellerVehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: vehicle.images.isNotEmpty
                ? Image.network(
                    vehicle.images.first,
                    width: 80,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vehicle.displayName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _chip(vehicle.type),
                    const SizedBox(width: 8),
                    _chip(vehicle.transmission),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "\$${vehicle.pricePerDay.toStringAsFixed(0)}/day",
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: vehicle.isAvailable
                      ? AppColors.success
                      : AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                vehicle.isAvailable ? "Available" : "Booked",
                style: TextStyle(
                  fontSize: 10,
                  color: vehicle.isAvailable
                      ? AppColors.success
                      : AppColors.error,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  _showDeleteDialog(context);
                },
                child: const Icon(Icons.delete_outline,
                    color: AppColors.error, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 80,
      height: 60,
      color: AppColors.surfaceGrey,
      child: const Icon(Icons.directions_car, size: 28),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(6),
      ),
      child:
          Text(text, style: const TextStyle(fontSize: 10, color: AppColors.textGrey)),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text("Delete Vehicle"),
        content: Text(
            "Are you sure you want to remove ${vehicle.displayName}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context.read<VehicleProvider>().deleteVehicle(vehicle.id);
              Navigator.pop(ctx);
            },
            child:
                const Text("Delete", style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
