import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../models/vehicle_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/vehicle_card.dart';
import '../../widgets/premium_widgets.dart';
import 'buyer_home_screen.dart';
import 'my_bookings_screen.dart';
import 'buyer_profile_screen.dart';
import 'vehicle_detail_screen.dart';

class BuyerMainScreen extends StatefulWidget {
  final int initialIndex;
  const BuyerMainScreen({super.key, this.initialIndex = 0});

  @override
  State<BuyerMainScreen> createState() => _BuyerMainScreenState();
}

class _BuyerMainScreenState extends State<BuyerMainScreen> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    BuyerHomeScreen(),
    MyBookingsScreen(),
    SavedVehiclesScreen(),
    _DummyChatScreen(), // Placeholder for chat
    BuyerProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    final auth = context.read<AuthProvider>();
    if (auth.user != null) {
      context.read<VehicleProvider>().listenToAvailableVehicles();
      context.read<BookingProvider>().listenToBuyerBookings(auth.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
        backgroundColor: AppColors.backgroundDark,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textGrey,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        elevation: 16,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 6.0, top: 8.0),
              child: Icon(Icons.explore_outlined, size: 24),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 6.0, top: 8.0),
              child: Icon(Icons.explore, size: 24),
            ),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 6.0, top: 8.0),
              child: Icon(Icons.calendar_today_outlined, size: 22),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 6.0, top: 8.0),
              child: Icon(Icons.calendar_month, size: 22),
            ),
            label: 'Trips',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 6.0, top: 8.0),
              child: Icon(Icons.favorite_border_rounded, size: 24),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 6.0, top: 8.0),
              child: Icon(Icons.favorite_rounded, size: 24),
            ),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 6.0, top: 8.0),
              child: Icon(Icons.chat_bubble_outline_rounded, size: 22),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 6.0, top: 8.0),
              child: Icon(Icons.chat_bubble_rounded, size: 22),
            ),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 6.0, top: 8.0),
              child: Icon(Icons.person_outline_rounded, size: 24),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 6.0, top: 8.0),
              child: Icon(Icons.person_rounded, size: 24),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _DummyChatScreen extends StatelessWidget {
  const _DummyChatScreen();
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: Text(
          "Chat coming soon!",
          style: TextStyle(color: AppColors.textGrey, fontSize: 16),
        ),
      ),
    );
  }
}

/// Fully featured Saved Vehicles & Wishlist Screen
class SavedVehiclesScreen extends StatefulWidget {
  const SavedVehiclesScreen({super.key});

  @override
  State<SavedVehiclesScreen> createState() => _SavedVehiclesScreenState();
}

class _SavedVehiclesScreenState extends State<SavedVehiclesScreen> {
  bool _isGridView = true;
  String _selectedSort = 'Recently Saved';
  final Set<String> _selectedForCompare = {};

  void _showCompareModal(List<VehicleModel> vehicles) {
    final toCompare = vehicles.where((v) => _selectedForCompare.contains(v.id)).toList();
    if (toCompare.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least 2 vehicles to compare"),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Side-by-Side Comparison",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close, color: AppColors.textGrey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: toCompare.map((v) {
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundDark,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: v.images.isNotEmpty
                              ? Image.network(
                                  v.images.first,
                                  height: 110,
                                  width: 180,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _fallbackImg(),
                                )
                              : _fallbackImg(),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          v.name.isNotEmpty ? v.name : "${v.brand} ${v.model}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textWhite),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Rs. ${v.pricePerDay.toStringAsFixed(0)} / day",
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const Divider(height: 24, color: AppColors.surfaceGrey),
                        _compareRow("Type", v.type),
                        _compareRow("Transmission", v.transmission),
                        _compareRow("Seats", "${v.seats} Seats"),
                        _compareRow("Rating", "${v.rating} ⭐"),
                        _compareRow("Location", v.location),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VehicleDetailScreen(vehicle: v),
                              ),
                            );
                          },
                          child: const Text("Book This Car"),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _compareRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
          Text(value, style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _fallbackImg() {
    return Container(
      height: 110,
      width: 180,
      color: AppColors.surfaceGrey,
      child: const Icon(Icons.directions_car, color: AppColors.textGrey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VehicleProvider>(
      builder: (context, vehicleProv, _) {
        final vehicles = vehicleProv.rawVehicles.isNotEmpty
            ? vehicleProv.rawVehicles.take(6).toList()
            : _sampleFavorites;

        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          appBar: AppBar(
            title: const Text('Saved & Wishlist'),
            backgroundColor: AppColors.backgroundDark,
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {
                  setState(() => _isGridView = !_isGridView);
                },
                icon: Icon(_isGridView ? Icons.format_list_bulleted_rounded : Icons.grid_view_rounded),
                tooltip: "Toggle View",
              ),
              if (_selectedForCompare.isNotEmpty)
                IconButton(
                  onPressed: () => _showCompareModal(vehicles),
                  icon: const Icon(Icons.compare_arrows_rounded, color: AppColors.primary),
                  tooltip: "Compare (${_selectedForCompare.length})",
                ),
            ],
          ),
          body: vehicles.isEmpty
              ? EmptyStateIllustration(
                  icon: Icons.favorite_border_rounded,
                  title: "No Saved Vehicles Yet",
                  description: "Tap the heart icon on any car, Tuk-Tuk, or bike in Sri Lanka to save it to your wishlist.",
                  buttonText: "Explore Vehicles",
                  onButtonPressed: () {
                    // Navigate to Explore
                  },
                )
              : Column(
                  children: [
                    // Top Bar: Compare toggle prompt & sort
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                "Select items to compare (${_selectedForCompare.length}/3)",
                                style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                              ),
                            ],
                          ),
                          _sortDropdown(),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _isGridView
                          ? GridView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.70,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                              ),
                              itemCount: vehicles.length,
                              itemBuilder: (context, idx) {
                                final v = vehicles[idx];
                                final isSelected = _selectedForCompare.contains(v.id);
                                return Stack(
                                  children: [
                                    Positioned.fill(
                                      child: VehicleCard(vehicle: v),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (isSelected) {
                                              _selectedForCompare.remove(v.id);
                                            } else {
                                              if (_selectedForCompare.length < 3) {
                                                _selectedForCompare.add(v.id);
                                              }
                                            }
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: isSelected ? AppColors.primary : Colors.black54,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected ? AppColors.primary : Colors.white,
                                            ),
                                          ),
                                          child: Icon(
                                            isSelected ? Icons.check : Icons.compare_arrows_rounded,
                                            size: 14,
                                            color: isSelected ? AppColors.textDark : AppColors.textWhite,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                              itemCount: vehicles.length,
                              itemBuilder: (context, idx) {
                                final v = vehicles[idx];
                                return Container(
                                  height: 170,
                                  margin: const EdgeInsets.only(bottom: 14),
                                  child: VehicleCard(vehicle: v),
                                );
                              },
                            ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _sortDropdown() {
    return PopupMenuButton<String>(
      initialValue: _selectedSort,
      onSelected: (val) => setState(() => _selectedSort = val),
      color: AppColors.cardDark,
      itemBuilder: (ctx) => const [
        PopupMenuItem(value: 'Recently Saved', child: Text("Recently Saved")),
        PopupMenuItem(value: 'Price: Low to High', child: Text("Price: Low to High")),
        PopupMenuItem(value: 'Top Rated', child: Text("Top Rated")),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Text(
              _selectedSort,
              style: const TextStyle(color: AppColors.textWhite, fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary, size: 16),
          ],
        ),
      ),
    );
  }

  static final List<VehicleModel> _sampleFavorites = [
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
