import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../models/booking_model.dart';
import '../../models/vehicle_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../widgets/premium_widgets.dart';
import 'add_vehicle_screen.dart';
import 'seller_bookings_screen.dart';
import 'my_vehicles_screen.dart';
import '../common/chat_message_screen.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  String _chartPeriod = '7 Days';

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    if (auth.user != null) {
      context.read<VehicleProvider>().listenToSellerVehicles(auth.user!.uid);
      context.read<BookingProvider>().listenToSellerBookings(auth.user!.uid);
    }
  }

  void _showPayoutModal() {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Bank Payout Settings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textWhite)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.success.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                  child: const Text("VERIFIED", style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _payoutRow(Icons.account_balance_rounded, "Commercial Bank of Ceylon", "A/C •••• 8492 • Colombo Branch"),
            _payoutRow(Icons.account_balance_wallet_rounded, "LankaPay QR / FriMi", "Instant Daily Payout Enabled"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payout request of Rs. 45,000 submitted!")));
              },
              child: const Text("Request Instant Payout • Rs. 45,000"),
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  Widget _payoutRow(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
        ],
      ),
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
            final auth = context.read<AuthProvider>();
            if (auth.user != null) {
              context.read<VehicleProvider>().listenToSellerVehicles(auth.user!.uid);
              context.read<BookingProvider>().listenToSellerBookings(auth.user!.uid);
            }
            await Future.delayed(const Duration(milliseconds: 600));
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Header: Seller Name & Verified Badge
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                  child: Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Text(
                                    "HOST DASHBOARD",
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  VerifiedBadge(text: "Lanka Verified Host"),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                auth.user?.name ?? "Lanka Ride Rentals",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textWhite,
                                ),
                              ),
                            ],
                          ),
                          // Payout Button
                          GestureDetector(
                            onTap: _showPayoutModal,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.cardDark,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary, size: 18),
                                  SizedBox(width: 6),
                                  Text("Payouts", style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // 2. Revenue & Fleet Stats Cards (2x2 Grid)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              icon: Icons.trending_up_rounded,
                              title: "This Month Earnings",
                              value: "Rs. 420,000",
                              subtitle: "+28% vs. last month",
                              subtitleColor: AppColors.success,
                              accentColor: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _buildMetricCard(
                              icon: Icons.directions_car_filled_rounded,
                              title: "Fleet Occupancy",
                              value: "82% Active",
                              subtitle: "14 of 17 on trips",
                              subtitleColor: AppColors.primary,
                              accentColor: AppColors.accentBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              icon: Icons.today_rounded,
                              title: "Today's Earnings",
                              value: "Rs. 18,500",
                              subtitle: "3 new reservations",
                              subtitleColor: AppColors.textGreyLight,
                              accentColor: AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _buildMetricCard(
                              icon: Icons.star_rounded,
                              title: "Host Rating",
                              value: "4.95 ⭐",
                              subtitle: "128 Verified Reviews",
                              subtitleColor: AppColors.textGreyLight,
                              accentColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Visual Revenue Bar Chart Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                      boxShadow: const [
                        BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 6)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text("Weekly Revenue Trend", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textWhite)),
                                SizedBox(height: 2),
                                Text("Mon - Sun Sri Lanka Earnings", style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundDark,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                              ),
                              child: Text(_chartPeriod, style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Visual Animated Bar Chart
                        SizedBox(
                          height: 140,
                          child: _buildRevenueBarChart(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 4. Quick Action Shortcuts
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: _quickActionBtn(
                          icon: Icons.add_circle_outline_rounded,
                          label: "Add Vehicle",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _quickActionBtn(
                          icon: Icons.directions_car_rounded,
                          label: "My Fleet",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const MyVehiclesScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _quickActionBtn(
                          icon: Icons.calendar_today_rounded,
                          label: "All Bookings",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SellerBookingsScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 5. Top Performing Vehicle Spotlight
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                  child: Consumer<VehicleProvider>(
                    builder: (context, vehicleProv, _) {
                      final topVehicle = vehicleProv.sellerVehicles.isNotEmpty
                          ? vehicleProv.sellerVehicles.first
                          : _sampleTopVehicle;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.2),
                              AppColors.cardDark,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: topVehicle.images.isNotEmpty
                                  ? Image.network(
                                      topVehicle.images.first,
                                      width: 90,
                                      height: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _fallbackImg(),
                                    )
                                  : _fallbackImg(),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "TOP PERFORMING VEHICLE",
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 9,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.success.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text("94% BOOKED", style: TextStyle(color: AppColors.success, fontSize: 9, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    topVehicle.displayName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textWhite),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "Rs. 184,000 earned (18 trips this month)",
                                    style: TextStyle(color: AppColors.textGreyLight, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              // 6. Pending Booking Requests Section (1-click Accept / Decline)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Text(
                            "Pending Booking Requests",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                          ),
                          SizedBox(width: 8),
                          VerifiedBadge(text: "Action Needed"),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SellerBookingsScreen()),
                          );
                        },
                        child: const Text(
                          "View All",
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 7. Pending Bookings List Feed
              Consumer<BookingProvider>(
                builder: (context, bookingProv, _) {
                  final pending = bookingProv.sellerBookings.isNotEmpty
                      ? bookingProv.sellerBookings.where((b) => b.status == 'pending').toList()
                      : _samplePendingBookings;

                  if (pending.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: const Center(
                          child: Text(
                            "All caught up! No pending requests at the moment.",
                            style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, idx) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                          child: _buildPendingBookingCard(context, pending[idx]),
                        );
                      },
                      childCount: pending.length,
                    ),
                  );
                },
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 50)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color subtitleColor,
    required Color accentColor,
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const Icon(Icons.arrow_outward_rounded, color: AppColors.textGrey, size: 16),
            ],
          ),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w900, fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: subtitleColor, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueBarChart() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final heights = [0.45, 0.65, 0.50, 0.75, 0.95, 1.0, 0.85];
    final values = ['14k', '21k', '16k', '28k', '38k', '42k', '32k'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(days.length, (idx) {
        final ratio = heights[idx];
        final isHighest = ratio == 1.0;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              values[idx],
              style: TextStyle(
                fontSize: 10,
                fontWeight: isHighest ? FontWeight.bold : FontWeight.normal,
                color: isHighest ? AppColors.primary : AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 26,
              height: 80 * ratio,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: isHighest
                      ? [AppColors.primary.withOpacity(0.6), AppColors.primary]
                      : [AppColors.backgroundDark, AppColors.cardDark],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isHighest ? AppColors.primary : Colors.white.withOpacity(0.1),
                ),
                boxShadow: isHighest
                    ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10)]
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              days[idx],
              style: TextStyle(
                fontSize: 11,
                fontWeight: isHighest ? FontWeight.bold : FontWeight.normal,
                color: isHighest ? AppColors.textWhite : AppColors.textGrey,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _quickActionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(color: AppColors.textWhite, fontSize: 11, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingBookingCard(BuildContext context, BookingModel b) {
    final bookingProv = context.read<BookingProvider>();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.warning.withOpacity(0.5)),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    child: Text(
                      b.buyerName.isNotEmpty ? b.buyerName[0] : "C",
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.buyerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textWhite)),
                      const Text("Verified DL • 5.0 ★ Guest", style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              Text(
                "Rs. ${b.totalPrice.toStringAsFixed(0)}",
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "${b.vehicleName} • ${b.totalDays} Days Rental",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textWhite),
          ),
          const SizedBox(height: 4),
          Text(
            "Pickup: ${b.pickupLocation ?? 'Colombo Area'}",
            style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
          ),
          const SizedBox(height: 16),

          // 1-Click Accept / Decline Buttons + Chat
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await bookingProv.updateBookingStatus(b.id, 'confirmed');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Booking #${b.id} Confirmed! Guest notified via SMS."), backgroundColor: AppColors.success),
                      );
                    }
                  },
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text("Accept Trip"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 44),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await bookingProv.updateBookingStatus(b.id, 'cancelled');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Booking declined.")),
                      );
                    }
                  },
                  icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.error),
                  label: const Text("Decline", style: TextStyle(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    minimumSize: const Size(0, 44),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatMessageScreen(
                        partnerName: b.buyerName,
                        vehicleTitle: b.vehicleName,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fallbackImg() {
    return Container(
      width: 90,
      height: 70,
      color: AppColors.surfaceGrey,
      child: const Icon(Icons.directions_car, color: AppColors.textGrey),
    );
  }

  static final VehicleModel _sampleTopVehicle = VehicleModel(
    id: 'sample_4',
    sellerId: 'seller_4',
    sellerName: 'Lanka Ride Rentals',
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
    rating: 4.95,
    totalTrips: 64,
    location: 'Colombo 07',
    createdAt: DateTime(2024, 1, 1),
  );

  static final List<BookingModel> _samplePendingBookings = [
    BookingModel(
      id: 'REQ-49201',
      vehicleId: 'sample_4',
      vehicleName: 'Toyota Prius Hybrid (2022)',
      vehicleImage: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=600&q=75',
      buyerId: 'user_99',
      buyerName: 'Shenal Fernando',
      buyerPhone: '+94 71 890 2341',
      sellerId: 'seller_4',
      sellerName: 'Lanka Ride Rentals',
      startDate: DateTime.now().add(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 5)),
      totalDays: 3,
      pricePerDay: 14000,
      totalPrice: 42000,
      status: 'pending',
      pickupLocation: 'Airport Delivery (BIA)',
      createdAt: DateTime.now(),
    ),
  ];
}
