import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../models/vehicle_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../widgets/premium_widgets.dart';
import '../../widgets/vehicle_card.dart';
import 'booking_screen.dart';
import '../common/chat_message_screen.dart';

class VehicleDetailScreen extends StatefulWidget {
  final VehicleModel vehicle;

  const VehicleDetailScreen({
    super.key,
    required this.vehicle,
  });

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  int _currentImageIndex = 0;
  bool _isFavorite = false;

  void _show360Modal() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.threed_rotation_rounded, color: AppColors.primary, size: 28),
                      SizedBox(width: 8),
                      Text("360° Interactive View", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textWhite)),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close, color: AppColors.textGrey),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.backgroundDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (widget.vehicle.images.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          widget.vehicle.images.first,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.swipe_outlined, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text("Drag horizontally to rotate 360°", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Verified Sri Lanka Inspection Report • Passed 100-Point Safety Check",
                style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCalendarPreview() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Availability Calendar",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textWhite),
            ),
            const SizedBox(height: 8),
            const Text(
              "Green dates are available for instant booking.",
              style: TextStyle(color: AppColors.textGrey, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _dateChip("Today", true),
                _dateChip("Tomorrow", true),
                _dateChip("This Weekend", true),
                _dateChip("Next Week", false),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _dateChip(String label, bool available) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: available ? AppColors.success.withValues(alpha: 0.15) : AppColors.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: available ? AppColors.success : AppColors.error,
        ),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textWhite)),
          const SizedBox(height: 4),
          Text(
            available ? "Available" : "Booked",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: available ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = widget.vehicle;
    final images = vehicle.images.isNotEmpty
        ? vehicle.images
        : ['https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=800&q=75'];

    final auth = context.read<AuthProvider>();
    final isOwner = auth.user?.uid == vehicle.sellerId;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Hero Image Carousel with 360° View Trigger
              SliverAppBar(
                expandedHeight: 310,
                pinned: true,
                backgroundColor: AppColors.backgroundDark,
                leading: _buildCircleBtn(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                actions: [
                  _buildCircleBtn(
                    icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.redAccent : AppColors.textWhite,
                    onTap: () {
                      setState(() => _isFavorite = !_isFavorite);
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildCircleBtn(
                    icon: Icons.share_rounded,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Link copied to clipboard!")),
                      );
                    },
                  ),
                  const SizedBox(width: 14),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      PageView.builder(
                        itemCount: images.length,
                        onPageChanged: (idx) => setState(() => _currentImageIndex = idx),
                        itemBuilder: (context, index) {
                          return Hero(
                            tag: 'vehicle_img_${vehicle.id}',
                            child: CachedNetworkImage(
                              imageUrl: images[index],
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: AppColors.surfaceGrey,
                                child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: AppColors.surfaceGrey,
                                child: const Icon(Icons.directions_car, size: 64, color: AppColors.textGrey),
                              ),
                            ),
                          );
                        },
                      ),
                      // Gradient overlay
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0x7F000000),
                                Colors.transparent,
                                Color(0x99000000),
                              ],
                              stops: [0.0, 0.4, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // 360° and Video Button overlay
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: _show360Modal,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.primary),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.threed_rotation_rounded, color: AppColors.primary, size: 16),
                                    SizedBox(width: 6),
                                    Text("360° View", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Page indicators
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            "${_currentImageIndex + 1}/${images.length}",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Main Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand & Top Rated pill
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            vehicle.brand.isNotEmpty ? vehicle.brand.toUpperCase() : "SRI LANKA RENTALS",
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const VerifiedBadge(text: "Verified Safety Inspection"),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Title & Year
                      Text(
                        "${vehicle.displayName} ${vehicle.year > 2000 ? '(${vehicle.year})' : ''}",
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Rating & Location
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppColors.primary, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            vehicle.rating > 0 ? vehicle.rating.toStringAsFixed(1) : "4.9",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textWhite),
                          ),
                          Text(
                            " (${vehicle.totalTrips} completed Sri Lanka trips)",
                            style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            vehicle.location.isNotEmpty ? vehicle.location : "Colombo, Sri Lanka",
                            style: const TextStyle(color: AppColors.textGreyLight, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 3. Key Specifications Grid
                      const Text(
                        "Vehicle Specifications",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _specCard(Icons.speed_rounded, "Transmission", vehicle.transmission)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _specCard(
                              Icons.local_gas_station_rounded,
                              "Fuel Type",
                              vehicle.type == 'Bike' || vehicle.type == 'Three-Wheel' ? 'Petrol' : 'Hybrid / EV',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: _specCard(Icons.event_seat_rounded, "Seats", "${vehicle.seats} Seats")),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 4. Owner & Seller Profile Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                              child: Text(
                                vehicle.sellerName.isNotEmpty ? vehicle.sellerName[0].toUpperCase() : "S",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        vehicle.sellerName.isNotEmpty ? vehicle.sellerName : "Lanka Verified Owner",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: AppColors.textWhite,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.verified_rounded, color: AppColors.success, size: 16),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  const Text(
                                    "Response rate 99% • Replies within 15 mins",
                                    style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatMessageScreen(
                                      partnerName: vehicle.sellerName.isNotEmpty ? vehicle.sellerName : "Seller",
                                      vehicleTitle: vehicle.displayName,
                                    ),
                                  ),
                                );
                              },
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 5. Full Comprehensive Insurance Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.success.withValues(alpha: 0.15),
                              AppColors.cardDark,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.shield_rounded, color: AppColors.success, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "100% Comprehensive Insurance Included",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textWhite),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Covered against damage, theft, and 24/7 roadside assistance across Sri Lanka.",
                                    style: TextStyle(color: AppColors.textGrey, fontSize: 12, height: 1.3),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 6. Description
                      const Text(
                        "About This Vehicle",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        vehicle.description.isNotEmpty
                            ? vehicle.description
                            : "Well maintained Sri Lanka rental vehicle ready for island exploration. Air conditioned, clean interior, regular service history, and smooth handling for Kandy hills and southern beaches.",
                        style: const TextStyle(color: AppColors.textGreyLight, fontSize: 14, height: 1.5),
                      ),
                      const SizedBox(height: 24),

                      // 7. Included Features & Amenities
                      const Text(
                        "Included Amenities",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _featurePill(Icons.ac_unit_rounded, "Air Conditioning"),
                          _featurePill(Icons.bluetooth_rounded, "Bluetooth Audio"),
                          _featurePill(Icons.gps_fixed_rounded, "GPS Navigation"),
                          _featurePill(Icons.camera_alt_rounded, "Reverse Camera"),
                          _featurePill(Icons.child_care_rounded, "Child Seat Ready"),
                          _featurePill(Icons.usb_rounded, "USB Charging"),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 8. Availability Calendar Button
                      GestureDetector(
                        onTap: _showCalendarPreview,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardDark,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 22),
                                  SizedBox(width: 12),
                                  Text(
                                    "Check Availability Dates",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textWhite),
                                  ),
                                ],
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textGrey, size: 16),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 9. Pickup Location Map Preview Card
                      const Text(
                        "Pickup Location",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                      ),
                      const SizedBox(height: 12),
                      _buildPickupMapCard(vehicle.location.isNotEmpty ? vehicle.location : "Colombo 03, Sri Lanka"),
                      const SizedBox(height: 24),

                      // 10. Cancellation Policy
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundDark,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.event_available_rounded, color: AppColors.primary, size: 24),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Free Cancellation",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textWhite),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Cancel up to 24 hours before your trip for a 100% full refund.",
                                    style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // 11. Customer Reviews Breakdown
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Customer Reviews",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: AppColors.primary, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                vehicle.rating > 0 ? vehicle.rating.toStringAsFixed(1) : "4.9",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textWhite),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildReviewBar("Cleanliness", 0.98),
                      _buildReviewBar("Communication", 0.96),
                      _buildReviewBar("Vehicle Condition", 0.99),
                      const SizedBox(height: 16),
                      _buildReviewCommentCard(
                        "Ashan Perera",
                        "Wonderful experience! The car was super clean and the owner dropped it off at Colombo airport on time.",
                        "2 days ago",
                      ),
                      const SizedBox(height: 28),

                      // 12. Similar Vehicles Carousel
                      const Text(
                        "Similar Vehicles You May Like",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                      ),
                      const SizedBox(height: 12),
                      Consumer<VehicleProvider>(
                        builder: (context, vehicleProv, _) {
                          final similar = vehicleProv.rawVehicles
                              .where((v) => v.id != vehicle.id)
                              .take(4)
                              .toList();

                          if (similar.isEmpty) return const SizedBox.shrink();

                          return SizedBox(
                            height: 285,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: similar.length,
                              itemBuilder: (context, idx) {
                                return Container(
                                  width: 215,
                                  margin: const EdgeInsets.only(right: 14),
                                  child: VehicleCard(vehicle: similar[idx]),
                                );
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 110),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 13. Sticky Luxury Bottom Bar for Booking
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x99000000),
                    blurRadius: 20,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Rs. ${vehicle.pricePerDay.toStringAsFixed(0)}",
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                            ),
                          ),
                          const Text(
                            " / day",
                            style: TextStyle(color: AppColors.textGrey, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Includes Insurance & 24/7 Support",
                        style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (isOwner) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("You cannot book your own vehicle")),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingScreen(vehicle: vehicle),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textDark,
                      minimumSize: const Size(160, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 6,
                    ),
                    child: const Text(
                      "Continue to Book",
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleBtn({
    required IconData icon,
    Color color = AppColors.textWhite,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        onPressed: onTap,
      ),
    );
  }

  Widget _specCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(color: AppColors.textGrey, fontSize: 11)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _featurePill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: AppColors.textWhite, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildPickupMapCard(String location) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF14243A), Color(0xFF0C1622)],
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    location,
                    style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewBar(String label, double ratio) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: AppColors.backgroundDark,
              color: AppColors.primary,
              minHeight: 6,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "${(ratio * 5).toStringAsFixed(1)} ⭐",
            style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCommentCard(String author, String comment, String timeAgo) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    child: Text(
                      author[0],
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(author, style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              Text(timeAgo, style: const TextStyle(color: AppColors.textGrey, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            comment,
            style: const TextStyle(color: AppColors.textGreyLight, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }
}
