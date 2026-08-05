import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../models/vehicle_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../widgets/vehicle_card.dart';
import '../../widgets/premium_widgets.dart';
import 'search_explore_screen.dart';
import 'vehicle_detail_screen.dart';
import '../common/notification_center_screen.dart';

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key});

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  String _currentCity = 'Colombo, Sri Lanka';
  int _bannerIndex = 0;
  late PageController _bannerController;
  Timer? _bannerTimer;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _promoBanners = [
    {
      'title': '30% off your first\nisland trip',
      'subtitle': 'Use code RENTX30 · ends Sunday',
      'tag': 'WEEKEND OFFER',
      'color_index': '0',
    },
    {
      'title': 'Earn rewards on\nevery booking',
      'subtitle': 'Redeem points for free rides',
      'tag': 'LOYALTY PROGRAM',
      'color_index': '1',
    },
  ];

  @override
  void initState() {
    super.initState();
    _bannerController = PageController(viewportFraction: 0.88);
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;
      setState(() {
        _bannerIndex = (_bannerIndex + 1) % _promoBanners.length;
        if (_bannerController.hasClients) {
          _bannerController.animateToPage(
            _bannerIndex,
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeInOut,
          );
        }
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehicleProvider>().listenToAvailableVehicles();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _showCityPickerDialog() {
    final cities = ['Colombo, Sri Lanka', 'Kandy, Sri Lanka', 'Galle, Sri Lanka', 'Negombo, Sri Lanka', 'Ella, Sri Lanka', 'Nuwara Eliya, Sri Lanka'];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Rental Location",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textWhite),
            ),
            const SizedBox(height: 4),
            const Text(
              "We will prioritize nearby vehicles across Sri Lanka.",
              style: TextStyle(color: AppColors.textGrey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ...cities.map((city) => ListTile(
                  leading: Icon(
                    Icons.location_on_rounded,
                    color: _currentCity == city ? AppColors.primary : AppColors.textGrey,
                  ),
                  title: Text(
                    city,
                    style: TextStyle(
                      color: _currentCity == city ? AppColors.primary : AppColors.textWhite,
                      fontWeight: _currentCity == city ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: _currentCity == city ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
                  onTap: () {
                    setState(() => _currentCity = city);
                    Navigator.pop(ctx);
                  },
                )),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showAiModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AiRecommendationModal(),
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => const _FilterModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.cardDark,
          onRefresh: () async {
            context.read<VehicleProvider>().listenToAvailableVehicles();
            await Future.delayed(const Duration(milliseconds: 700));
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Header: Greeting, Notifications, Avatar, Location, Weather
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Good morning, Kavindu",
                            style: TextStyle(
                              color: AppColors.textGreyLight,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const NotificationCenterScreen()),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardDark,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.notifications_none_rounded, color: AppColors.textWhite, size: 20),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.surfaceGrey,
                                child: Text("KS", style: TextStyle(color: AppColors.textWhite, fontSize: 13, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _showCityPickerDialog,
                            child: Row(
                              children: [
                                const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  _currentCity.split(',').first,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textWhite,
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textGrey, size: 18),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.wb_cloudy_outlined, color: AppColors.textGrey, size: 16),
                          const SizedBox(width: 4),
                          const Text(
                            "29° · Light showers",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.cardDark,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: AppColors.textWhite, fontSize: 14),
                            onSubmitted: (val) {
                              if (val.trim().isNotEmpty) {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => SearchExploreScreen(initialQuery: val.trim()),
                                ));
                                _searchController.clear();
                              }
                            },
                            decoration: InputDecoration(
                              hintText: "Search vehicles, brands...",
                              hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
                              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textGrey, size: 20),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.mic_none_rounded, color: AppColors.primary, size: 20),
                                onPressed: _showAiModal, // Voice placeholder
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _showFilterModal,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.tune_rounded, color: AppColors.textDark, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Promotional Carousel Slider
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 140,
                  child: PageView.builder(
                    controller: _bannerController,
                    onPageChanged: (i) => setState(() => _bannerIndex = i),
                    itemCount: _promoBanners.length,
                    itemBuilder: (context, idx) {
                      final b = _promoBanners[idx];
                      return _buildBannerCard(b);
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // 4. Categories Selector Bar
              SliverToBoxAdapter(
                child: Consumer<VehicleProvider>(
                  builder: (context, vehicleProv, _) {
                    final categories = ['Cars', 'SUV', 'Bike', 'Scooter', 'Van'];
                    final icons = [
                      Icons.directions_car_outlined,
                      Icons.airport_shuttle_outlined,
                      Icons.pedal_bike_outlined,
                      Icons.moped_outlined,
                      Icons.directions_bus_outlined,
                    ];
                    return SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: categories.length,
                        itemBuilder: (context, idx) {
                          final cat = categories[idx];
                          final icon = icons[idx];
                          final isSelected = vehicleProv.selectedType == (cat == 'Cars' ? 'Car' : cat);
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () {
                                final targetType = cat == 'Cars' ? 'Car' : cat;
                                if (vehicleProv.selectedType == targetType) {
                                  vehicleProv.setType('All');
                                } else {
                                  vehicleProv.setType(targetType);
                                }
                              },
                              child: Container(
                                width: 75,
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.backgroundDark : AppColors.cardDark,
                                  borderRadius: BorderRadius.circular(16),
                                  border: isSelected 
                                      ? Border.all(color: AppColors.primary, width: 1.5)
                                      : Border.all(color: Colors.transparent),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      icon,
                                      size: 24,
                                      color: isSelected ? AppColors.primary : AppColors.textWhite,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      cat,
                                      style: TextStyle(
                                        color: isSelected ? AppColors.textWhite : AppColors.textWhite,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              // 5. Section Header: Recommended for you
              _sectionHeader(
                "Recommended for you",
                "See all",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchExploreScreen()),
                  );
                },
              ),

              // 6. Vehicles Horizontal Stream / Carousel
              SliverToBoxAdapter(
                child: Consumer<VehicleProvider>(
                  builder: (context, vehicleProv, _) {
                    final vehicles = vehicleProv.vehicles;

                    if (vehicles.isEmpty) {
                      return const SizedBox(
                        height: 200,
                        child: Center(
                          child: Text(
                            "No vehicles found for this filter.",
                            style: TextStyle(color: AppColors.textGrey, fontSize: 16),
                          ),
                        ),
                      );
                    }

                    return SizedBox(
                      height: 290,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: vehicles.length,
                        itemBuilder: (context, idx) {
                          return Container(
                            width: 235,
                            margin: const EdgeInsets.only(right: 16),
                            child: VehicleCard(vehicle: vehicles[idx]),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              // 7. Section Header: Nearby vehicles
              _sectionHeader(
                "Nearby vehicles",
                "Map",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchExploreScreen()),
                  );
                },
              ),
              
              // 8. Vertical Grid of Vehicles
              Consumer<VehicleProvider>(
                builder: (context, vehicleProv, _) {
                  final vehicles = vehicleProv.vehicles;

                  if (vehicles.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(40),
                        alignment: Alignment.center,
                        child: const Text(
                          "Try resetting your filters",
                          style: TextStyle(color: AppColors.textGrey, fontSize: 14),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.70,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return VehicleCard(vehicle: vehicles[index % vehicles.length]);
                        },
                        childCount: vehicles.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAiModal,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textDark,
        elevation: 8,
        child: const Icon(Icons.auto_awesome_rounded),
      ),
    );
  }

  Widget _buildBannerCard(Map<String, String> b) {
    bool isFirst = b['color_index'] == '0';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isFirst ? const Color(0xFF1E2536) : AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            b['tag']!,
            style: TextStyle(
              color: isFirst ? AppColors.primary : const Color(0xFF4ADE80),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            b['title']!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            b['subtitle']!,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, String action, VoidCallback onTap) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
            GestureDetector(
              onTap: onTap,
              child: Text(
                action,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _FilterModal extends StatefulWidget {
  const _FilterModal();

  @override
  State<_FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<_FilterModal> {
  String _tempTransmission = 'All';
  double _tempMaxPrice = 50000.0;

  @override
  void initState() {
    super.initState();
    final prov = context.read<VehicleProvider>();
    _tempTransmission = prov.selectedTransmission;
    _tempMaxPrice = prov.maxPrice;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Filter Vehicles",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: AppColors.textGrey),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text("Transmission", style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildTransChip('All'),
              const SizedBox(width: 10),
              _buildTransChip('Auto'),
              const SizedBox(width: 10),
              _buildTransChip('Manual'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Max Price per Day", style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold)),
              Text("Rs. ${_tempMaxPrice.toStringAsFixed(0)}", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: _tempMaxPrice,
            min: 2000,
            max: 50000,
            divisions: 48,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.textGrey,
            onChanged: (val) {
              setState(() => _tempMaxPrice = val);
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<VehicleProvider>().resetFilters();
                    Navigator.pop(context);
                  },
                  child: const Text("Reset"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final prov = context.read<VehicleProvider>();
                    prov.setTransmission(_tempTransmission);
                    prov.setMaxPrice(_tempMaxPrice);
                    Navigator.pop(context);
                  },
                  child: const Text("Apply Filters"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransChip(String label) {
    final isSelected = _tempTransmission == label;
    return GestureDetector(
      onTap: () => setState(() => _tempTransmission = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.1)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.textDark : AppColors.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
