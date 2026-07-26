import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../models/vehicle_model.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/vehicle_card.dart';

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key});

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final String _selectedLocation = 'Los Angeles, CA';

  // Static cached sample vehicles list to prevent re-instantiating objects on rebuilds
  static final List<VehicleModel> _sampleVehicles = [
    VehicleModel(
      id: 'sample_1',
      sellerId: 'seller_1',
      sellerName: 'Premium Rentals',
      name: 'Model S Plaid',
      brand: 'TESLA',
      model: 'Model S Plaid',
      year: 2024,
      color: 'Midnight Black',
      type: 'Electric',
      transmission: 'Auto',
      seats: 5,
      pricePerDay: 249,
      description: 'Experience electric thrill with 0-60 in 1.99s.',
      features: const ['Autopilot', 'GPS', 'Bluetooth', 'Heated Seats'],
      images: const [
        'https://images.unsplash.com/photo-1617788138017-80ad40651399?auto=format&fit=crop&w=600&q=75',
      ],
      rating: 4.9,
      totalTrips: 42,
      location: '1.2 km',
      createdAt: DateTime(2024, 1, 1),
    ),
    VehicleModel(
      id: 'sample_2',
      sellerId: 'seller_2',
      sellerName: 'Exotic Motors',
      name: '911 Carrera',
      brand: 'PORSCHE',
      model: '911 Carrera',
      year: 2024,
      color: 'GT Silver',
      type: 'Sedan',
      transmission: 'Auto',
      seats: 2,
      pricePerDay: 320,
      description: 'Iconic sports car performance and luxury style.',
      features: const ['Sports Exhaust', 'Bose Audio', 'Leather Seats'],
      images: const [
        'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=600&q=75',
      ],
      rating: 4.9,
      totalTrips: 28,
      location: '3.8 km',
      createdAt: DateTime(2024, 1, 1),
    ),
    VehicleModel(
      id: 'sample_3',
      sellerId: 'seller_3',
      sellerName: 'Luxury Drive',
      name: 'M4 Competition',
      brand: 'BMW',
      model: 'M4 Competition',
      year: 2023,
      color: 'Isle of Man Green',
      type: 'Sedan',
      transmission: 'Auto',
      seats: 4,
      pricePerDay: 210,
      description: 'Uncompromising power and precision engineering.',
      features: const ['M Carbon Seats', 'Head-Up Display', 'Harman Kardon'],
      images: const [
        'https://images.unsplash.com/photo-1555215695-3004980ad54e?auto=format&fit=crop&w=600&q=75',
      ],
      rating: 4.8,
      totalTrips: 35,
      location: '2.5 km',
      createdAt: DateTime(2024, 1, 1),
    ),
    VehicleModel(
      id: 'sample_4',
      sellerId: 'seller_4',
      sellerName: 'Urban Rentals',
      name: 'AMG GT Coupe',
      brand: 'MERCEDES',
      model: 'AMG GT Coupe',
      year: 2024,
      color: 'Obsidian Black',
      type: 'SUV',
      transmission: 'Auto',
      seats: 2,
      pricePerDay: 290,
      description: 'Pure performance V8 biturbo luxury supercar.',
      features: const ['Burmester Sound', 'Panoramadach', 'AMG Track Pace'],
      images: const [
        'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?auto=format&fit=crop&w=600&q=75',
      ],
      rating: 4.9,
      totalTrips: 19,
      location: '4.1 km',
      createdAt: DateTime(2024, 1, 1),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final userInitials = (user?.name.isNotEmpty ?? false)
        ? user!.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'AK';

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Top Location Header & User Avatar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Location selector
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.location_on,
                              color: AppColors.primary,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "Current location",
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () {},
                          child: Row(
                            children: [
                              Text(
                                _selectedLocation,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textWhite,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppColors.textWhite,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Action Buttons (Notification Bell & Profile Avatar)
                    Row(
                      children: [
                        // Notification Bell with Badge Dot
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.cardDark,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.05),
                                ),
                              ),
                              child: const Icon(
                                Icons.notifications_none_rounded,
                                color: AppColors.textWhite,
                                size: 22,
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 12,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        // Avatar Badge
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              userInitials,
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 2. Main Headline
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      fontFamily: 'Roboto',
                    ),
                    children: [
                      TextSpan(
                        text: "Find your ",
                        style: TextStyle(color: AppColors.textWhite),
                      ),
                      TextSpan(
                        text: "perfect drive",
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Search Bar & Filter Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // Search Input Box
                    Expanded(
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.search_rounded,
                              color: AppColors.textGrey,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (val) {
                                  setState(() {
                                    _searchQuery = val.trim().toLowerCase();
                                  });
                                },
                                style: const TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: 14,
                                ),
                                decoration: const InputDecoration(
                                  hintText: "Search cars, brands, models...",
                                  hintStyle: TextStyle(
                                    color: AppColors.textGrey,
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  fillColor: Colors.transparent,
                                  filled: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            if (_searchQuery.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.close, color: AppColors.textGrey, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Yellow Accent Filter Button
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x4DFFD027),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.tune_rounded,
                          color: AppColors.textDark,
                          size: 24,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Horizontal Category Filters
            SliverToBoxAdapter(
              child: Consumer<VehicleProvider>(
                builder: (context, vehicleProvider, _) {
                  final categories = [
                    {'name': 'All', 'icon': Icons.directions_car_rounded},
                    {'name': 'Electric', 'icon': Icons.bolt_rounded},
                    {'name': 'Sedan', 'icon': Icons.minor_crash_rounded},
                    {'name': 'SUV', 'icon': Icons.airport_shuttle_rounded},
                    {'name': 'Luxury', 'icon': Icons.stars_rounded},
                  ];

                  return Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: SizedBox(
                      height: 44,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          final name = cat['name'] as String;
                          final icon = cat['icon'] as IconData;
                          final isSelected = vehicleProvider.selectedType == name;

                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () => vehicleProvider.setType(name),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.cardDark,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.white.withValues(alpha: 0.05),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      icon,
                                      size: 18,
                                      color: isSelected
                                          ? AppColors.textDark
                                          : AppColors.textWhite,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      name,
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppColors.textDark
                                            : AppColors.textWhite,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
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

            // 5. Promotional Offer Banner ("LIMITED OFFER")
            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Container(
                    height: 170,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF2563EB),
                          Color(0xFF3B82F6),
                          Color(0xFF1D4ED8),
                        ],
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x552563EB),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Decorative background circular shapes
                        Positioned(
                          right: -30,
                          bottom: -40,
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 40,
                          top: -30,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                        ),
                        // Content
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // "LIMITED OFFER" Tag Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  "LIMITED OFFER",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              // Title Headline
                              const Text(
                                "30% off your\nfirst weekend rental",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                              // "Claim now" Button
                              ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Promo code claimed! 30% discount applied."),
                                      backgroundColor: AppColors.accentBlue,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF1D4ED8),
                                  minimumSize: const Size(120, 38),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 18),
                                ),
                                child: const Text(
                                  "Claim now",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 6. Section Title: "Popular Cars" & "See all"
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Popular Cars",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        "See all",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 7. Popular Cars Grid Section
            Consumer<VehicleProvider>(
              builder: (context, vehicleProvider, _) {
                // Combine Firestore vehicles with sample data if Firestore has 0 vehicles
                final sourceVehicles = vehicleProvider.vehicles.isNotEmpty
                    ? vehicleProvider.vehicles
                    : _sampleVehicles;

                // Filter by search query if user typed anything
                final vehicles = _searchQuery.isEmpty
                    ? sourceVehicles
                    : sourceVehicles.where((v) {
                        final query = _searchQuery;
                        return v.name.toLowerCase().contains(query) ||
                            v.brand.toLowerCase().contains(query) ||
                            v.model.toLowerCase().contains(query);
                      }).toList();

                if (vehicles.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 56,
                              color: AppColors.textGrey,
                            ),
                            SizedBox(height: 14),
                            Text(
                              "No matching vehicles found",
                              style: TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Try searching with another keyword or category",
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 12,
                              ),
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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return VehicleCard(vehicle: vehicles[index]);
                      },
                      childCount: vehicles.length,
                    ),
                  ),
                );
              },
            ),

            // Extra space at bottom to prevent bottom nav bar overlap
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }
}
