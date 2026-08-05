import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../models/vehicle_model.dart';
import '../../providers/vehicle_provider.dart';
import '../../widgets/premium_widgets.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehicleProvider>().listenToAvailableVehicles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.admin_panel_settings_rounded, color: AppColors.primary, size: 24),
            SizedBox(width: 8),
            Text("RentX Lanka • Admin Control"),
          ],
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary),
            ),
            child: const Text(
              "SUPERADMIN",
              style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Navigation Tabs
          Container(
            color: AppColors.cardDark,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _adminTab(0, "Platform Stats", Icons.analytics_rounded),
                _adminTab(1, "Vehicle Approvals", Icons.verified_user_rounded),
                _adminTab(2, "Host Accounts", Icons.people_alt_rounded),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.surfaceGrey),

          // 2. Tab Views
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _buildStatsTab(),
                _buildVehicleApprovalsTab(),
                _buildHostAccountsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _adminTab(int index, String label, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.textDark : AppColors.textGrey,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.textDark : AppColors.textGrey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TAB 1: Platform Overview Statistics
  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Sri Lanka Marketplace Metrics",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textWhite),
          ),
          const SizedBox(height: 4),
          const Text("Live data from across 9 provinces", style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _statCard(
                  title: "Total Gross GMV",
                  value: "Rs. 8.4M",
                  changeText: "+34% this month",
                  changeColor: AppColors.success,
                  icon: Icons.monetization_on_rounded,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _statCard(
                  title: "10% Platform Revenue",
                  value: "Rs. 840K",
                  changeText: "+28% net fees",
                  changeColor: AppColors.primary,
                  icon: Icons.account_balance_wallet_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _statCard(
                  title: "Verified Users",
                  value: "4,280",
                  changeText: "284 active today",
                  changeColor: AppColors.accentBlue,
                  icon: Icons.person_add_rounded,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _statCard(
                  title: "Active Fleet Cars",
                  value: "142",
                  changeText: "18 pending review",
                  changeColor: AppColors.warning,
                  icon: Icons.directions_car_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            "Platform Health & Safety",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textWhite),
          ),
          const SizedBox(height: 12),
          _healthCard("Insurance Claims Rate", "0.2% (Extremely low)", Icons.shield_rounded, AppColors.success),
          _healthCard("Average Response Time", "14 minutes", Icons.speed_rounded, AppColors.primary),
          _healthCard("Customer CSAT Score", "4.92 / 5.0", Icons.star_rounded, AppColors.success),
        ],
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required String changeText,
    required Color changeColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
              Icon(icon, color: AppColors.primary, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w900, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            changeText,
            style: TextStyle(color: changeColor, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _healthCard(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textWhite)),
          ),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  // TAB 2: Vehicle Approvals & Inspection
  Widget _buildVehicleApprovalsTab() {
    return Consumer<VehicleProvider>(
      builder: (context, vehicleProv, _) {
        final vehicles = vehicleProv.rawVehicles.isNotEmpty
            ? vehicleProv.rawVehicles
            : _sampleAdminVehicles;

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: vehicles.length,
          itemBuilder: (context, idx) {
            final v = vehicles[idx];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: v.images.isNotEmpty
                            ? Image.network(v.images.first, width: 85, height: 65, fit: BoxFit.cover)
                            : Container(width: 85, height: 65, color: AppColors.surfaceGrey),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              v.displayName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textWhite),
                            ),
                            Text(
                              "Host: ${v.sellerName} • Rs. ${v.pricePerDay.toStringAsFixed(0)} / day",
                              style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Location: ${v.location}",
                              style: const TextStyle(color: AppColors.textGreyLight, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: AppColors.surfaceGrey),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("${v.displayName} Approved & Verified!"), backgroundColor: AppColors.success),
                            );
                          },
                          icon: const Icon(Icons.check_rounded, size: 16),
                          label: const Text("Approve & Verify"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 42),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("${v.displayName} sent back for revision."), backgroundColor: AppColors.error),
                            );
                          },
                          icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.error),
                          label: const Text("Reject", style: TextStyle(color: AppColors.error)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error),
                            minimumSize: const Size(0, 42),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // TAB 3: Host Account Verification
  Widget _buildHostAccountsTab() {
    final hosts = [
      {'name': 'Lanka Ride Rentals', 'city': 'Colombo 03', 'fleet': '8 Vehicles', 'status': 'Verified DL & Tax ID'},
      {'name': 'Island TukTuk Tours', 'city': 'Negombo', 'fleet': '12 Three-Wheels', 'status': 'Verified Host'},
      {'name': 'Royal Lanka Cabs', 'city': 'Colombo 07', 'fleet': '5 Hybrids', 'status': 'Pending NIC Check'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: hosts.length,
      itemBuilder: (context, idx) {
        final h = hosts[idx];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    child: Text(
                      h['name']![0],
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(h['name']!, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textWhite, fontSize: 16)),
                      Text("${h['city']} • ${h['fleet']}", style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        h['status']!,
                        style: TextStyle(
                          color: h['status']!.contains('Verified') ? AppColors.success : AppColors.warning,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Host profile ${h['name']} inspected.")),
                  );
                },
                icon: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textGrey, size: 16),
              ),
            ],
          ),
        );
      },
    );
  }

  static final List<VehicleModel> _sampleAdminVehicles = [
    VehicleModel(
      id: 'sample_1',
      sellerId: 'seller_1',
      sellerName: 'Lanka Ride Rentals',
      name: 'Honda Dio 110',
      brand: 'HONDA',
      model: 'Dio 110',
      year: 2023,
      color: 'Matte Blue',
      type: 'Bike',
      transmission: 'Auto',
      seats: 2,
      pricePerDay: 3500,
      description: 'Fuel efficient scooter perfect for Colombo traffic.',
      images: const ['https://images.unsplash.com/photo-1558981806-ec527fa84c39?auto=format&fit=crop&w=600&q=75'],
      rating: 4.9,
      totalTrips: 58,
      location: 'Colombo 03',
      createdAt: DateTime(2024, 1, 1),
    ),
    VehicleModel(
      id: 'sample_4',
      sellerId: 'seller_4',
      sellerName: 'Royal Lanka Cabs',
      name: 'Toyota Prius Hybrid',
      brand: 'TOYOTA',
      model: 'Prius Hybrid',
      year: 2022,
      color: 'Pearl White',
      type: 'Car',
      transmission: 'Auto',
      seats: 5,
      pricePerDay: 14000,
      description: 'Smooth hybrid sedan with high comfort and great fuel economy.',
      images: const ['https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=600&q=75'],
      rating: 4.9,
      totalTrips: 64,
      location: 'Colombo 07',
      createdAt: DateTime(2024, 1, 1),
    ),
  ];
}
