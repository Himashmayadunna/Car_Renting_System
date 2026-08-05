import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../models/vehicle_model.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/auth_provider.dart';
import 'add_vehicle_screen.dart';

class MyVehiclesScreen extends StatefulWidget {
  const MyVehiclesScreen({super.key});

  @override
  State<MyVehiclesScreen> createState() => _MyVehiclesScreenState();
}

class _MyVehiclesScreenState extends State<MyVehiclesScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.user != null) {
        context.read<VehicleProvider>().listenToSellerVehicles(auth.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          "My Fleet Management",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
              );
            },
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
            tooltip: "Add New Vehicle",
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: AppColors.textDark),
        label: const Text(
          "Add Vehicle",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<VehicleProvider>(
        builder: (context, vehicleProv, _) {
          // If no seller vehicles found, use rawVehicles as sample preview
          final allVehicles = vehicleProv.sellerVehicles.isNotEmpty
              ? vehicleProv.sellerVehicles
              : vehicleProv.rawVehicles;

          final filtered = allVehicles.where((v) {
            if (_selectedFilter == 'Available') return v.isAvailable;
            if (_selectedFilter == 'Rented') return !v.isAvailable;
            return true;
          }).toList();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Fleet Stats Banner
              SliverToBoxAdapter(
                child: _buildFleetStatsCard(allVehicles),
              ),

              // 2. Filter Chips
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip("All", "All (${allVehicles.length})"),
                        const SizedBox(width: 8),
                        _buildFilterChip("Available", "Available (${allVehicles.where((v) => v.isAvailable).length})"),
                        const SizedBox(width: 8),
                        _buildFilterChip("Rented", "Rented (${allVehicles.where((v) => !v.isAvailable).length})"),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Vehicles List
              filtered.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 60),
                        child: Column(
                          children: [
                            Icon(Icons.directions_car_filled_outlined, size: 64, color: AppColors.textGrey.withOpacity(0.4)),
                            const SizedBox(height: 16),
                            const Text(
                              "No vehicles found in this category",
                              style: TextStyle(color: AppColors.textGrey, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, idx) {
                          final v = filtered[idx];
                          return _buildVehicleItemCard(context, v);
                        },
                        childCount: filtered.length,
                      ),
                    ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFleetStatsCard(List<VehicleModel> vehicles) {
    double totalDailyValue = 0;
    for (var v in vehicles) {
      totalDailyValue += v.pricePerDay;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.18),
            AppColors.cardDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Host Fleet Overview",
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "94% ACTIVE",
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _statMetric(
                  "Total Fleet",
                  "${vehicles.length} Units",
                  Icons.directions_car_rounded,
                  AppColors.primary,
                ),
              ),
              Expanded(
                child: _statMetric(
                  "Daily Revenue Cap",
                  "Rs. ${totalDailyValue.toStringAsFixed(0)}",
                  Icons.account_balance_wallet_rounded,
                  AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statMetric(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 11),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final isSelected = _selectedFilter == filterKey;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filterKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.textDark : AppColors.textWhite,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleItemCard(BuildContext context, VehicleModel v) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with status badge
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    v.images.isNotEmpty
                        ? v.images.first
                        : 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=600&q=75',
                    width: 76,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, _, __) => Container(
                      width: 76,
                      height: 56,
                      color: AppColors.surfaceGrey,
                      child: const Icon(Icons.directions_car, color: AppColors.textGrey),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        v.displayName.isNotEmpty ? v.displayName : v.name,
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            "${v.type} • ${v.transmission}",
                            style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.star_rounded, color: AppColors.primary, size: 14),
                          Text(
                            " ${v.rating.toStringAsFixed(1)}",
                            style: const TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: (v.isAvailable ? AppColors.success : AppColors.warning).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (v.isAvailable ? AppColors.success : AppColors.warning).withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    v.isAvailable ? "AVAILABLE" : "IN RENTAL",
                    style: TextStyle(
                      color: v.isAvailable ? AppColors.success : AppColors.warning,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.surfaceGrey),

          // Price & Actions footer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Daily Rental Rate",
                      style: TextStyle(color: AppColors.textGrey, fontSize: 11),
                    ),
                    Text(
                      "Rs. ${v.pricePerDay.toStringAsFixed(0)} / day",
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("AI Price Optimizer recommended Rs. ${(v.pricePerDay * 1.05).toStringAsFixed(0)}/day for peak demand!"),
                            backgroundColor: AppColors.accentBlue,
                          ),
                        );
                      },
                      icon: const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.primary),
                      label: const Text("AI Price", style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surfaceGrey,
                        foregroundColor: AppColors.textWhite,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      child: const Text("Edit", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

