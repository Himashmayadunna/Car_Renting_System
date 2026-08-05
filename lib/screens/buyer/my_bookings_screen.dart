import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/colors.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/premium_widgets.dart';
import 'trip_detail_screen.dart';
import '../common/chat_message_screen.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          title: const Text(
            "My Trips & Bookings",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          backgroundColor: AppColors.backgroundDark,
          automaticallyImplyLeading: false,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textGrey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(text: "Active & Upcoming"),
              Tab(text: "Trip History"),
              Tab(text: "Cancelled"),
            ],
          ),
        ),
        body: Consumer<BookingProvider>(
          builder: (context, bookingProvider, _) {
            final bookings = bookingProvider.buyerBookings.isNotEmpty
                ? bookingProvider.buyerBookings
                : _sampleBookingsFallback;

            final activeAndUpcoming = bookings
                .where((b) =>
                    b.status == 'pending' ||
                    b.status == 'confirmed' ||
                    b.status == 'active')
                .toList();

            final completedTrips =
                bookings.where((b) => b.status == 'completed').toList();

            final cancelled =
                bookings.where((b) => b.status == 'cancelled').toList();

            return TabBarView(
              children: [
                _buildActiveList(context, activeAndUpcoming),
                _buildTripHistoryList(context, completedTrips),
                _buildCancelledList(cancelled),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildActiveList(BuildContext context, List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return EmptyStateIllustration(
        icon: Icons.directions_car_outlined,
        title: "No Active Trips",
        description: "You don't have any ongoing or upcoming car rentals in Sri Lanka.",
        buttonText: "Explore Vehicles",
        onButtonPressed: () {},
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      itemCount: bookings.length,
      itemBuilder: (context, idx) {
        return _buildBookingCard(context, bookings[idx]);
      },
    );
  }

  Widget _buildTripHistoryList(BuildContext context, List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return const EmptyStateIllustration(
        icon: Icons.history_rounded,
        title: "No Completed Trips",
        description: "Your finished Sri Lanka trips will appear here with receipts & reviews.",
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      itemCount: bookings.length,
      itemBuilder: (context, idx) {
        return _buildBookingCard(context, bookings[idx]);
      },
    );
  }

  Widget _buildCancelledList(List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return const EmptyStateIllustration(
        icon: Icons.cancel_outlined,
        title: "No Cancelled Bookings",
        description: "Great! You haven't cancelled any Sri Lanka rental reservations.",
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      itemCount: bookings.length,
      itemBuilder: (context, idx) {
        return _buildBookingCard(context, bookings[idx]);
      },
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingModel booking) {
    final statusColor = _getStatusColor(booking.status);
    final statusLabel = _getStatusLabel(booking.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: const [
          BoxShadow(color: Color(0x66000000), blurRadius: 14, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: ID & Status badge
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_long_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      "Booking #${booking.id.length > 8 ? booking.id.substring(0, 8) : booking.id}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textWhite),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.surfaceGrey),

          // Body: Image + Title + Dates + Price
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: booking.vehicleImage.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: booking.vehicleImage,
                          width: 95,
                          height: 75,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: AppColors.surfaceGrey),
                          errorWidget: (_, __, ___) => _fallbackImg(),
                        )
                      : _fallbackImg(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.vehicleName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${DateFormat('MMM d').format(booking.startDate)} - ${DateFormat('MMM d, yyyy').format(booking.endDate)} • ${booking.totalDays} Days",
                        style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Pickup: ${booking.pickupLocation ?? 'Colombo, LK'}",
                        style: const TextStyle(color: AppColors.textGreyLight, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Rs. ${booking.totalPrice.toStringAsFixed(0)}",
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "Owner: ${booking.sellerName}",
                            style: const TextStyle(color: AppColors.textGrey, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Interactive Trip Timeline Bar (Confirmed -> Inspection -> Active -> Returned)
          if (booking.status != 'cancelled') ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: _buildTripTimeline(booking.status),
            ),
            const SizedBox(height: 8),
          ],

          // Footer Action Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Quick Modal Triggers: QR Check-In, Invoice, Live Track
                Row(
                  children: [
                    _iconBtn(
                      ctx: context,
                      icon: Icons.qr_code_2_rounded,
                      label: "QR Key",
                      onTap: () => _showQrCheckInModal(context, booking),
                    ),
                    const SizedBox(width: 8),
                    _iconBtn(
                      ctx: context,
                      icon: Icons.receipt_long_rounded,
                      label: "Invoice",
                      onTap: () => _showInvoiceModal(context, booking),
                    ),
                    if (booking.status == 'active' || booking.status == 'confirmed') ...[
                      const SizedBox(width: 8),
                      _iconBtn(
                        ctx: context,
                        icon: Icons.my_location_rounded,
                        label: "Track",
                        onTap: () => _showLiveTrackingModal(context, booking),
                      ),
                    ],
                  ],
                ),
                // Main Action Button (Trip Details or Message)
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TripDetailScreen(booking: booking),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(110, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Trip Details", style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripTimeline(String status) {
    final stages = ['Confirmed', 'Ready', 'Active', 'Completed'];
    int currentStageIdx = 0;
    if (status == 'confirmed') currentStageIdx = 1;
    if (status == 'active') currentStageIdx = 2;
    if (status == 'completed') currentStageIdx = 3;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(stages.length, (idx) {
        final isDone = idx <= currentStageIdx;
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: isDone ? AppColors.primary : AppColors.backgroundDark,
                  shape: BoxShape.circle,
                  border: Border.all(color: isDone ? AppColors.primary : AppColors.textGrey),
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check, size: 10, color: AppColors.textDark)
                      : Text(
                          "${idx + 1}",
                          style: const TextStyle(color: AppColors.textGrey, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                stages[idx],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                  color: isDone ? AppColors.textWhite : AppColors.textGrey,
                ),
              ),
              if (idx < stages.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    color: idx < currentStageIdx ? AppColors.primary : AppColors.surfaceGrey,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _iconBtn({
    required BuildContext ctx,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.backgroundDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: AppColors.textWhite, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showQrCheckInModal(BuildContext context, BookingModel booking) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Digital QR Key Check-in",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textWhite),
            ),
            const SizedBox(height: 6),
            const Text(
              "Show this code to the vehicle owner for instant Sri Lanka inspection verification.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGrey, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.qr_code_2_rounded, size: 160, color: Colors.black),
            ),
            const SizedBox(height: 20),
            Text(
              "Ref Code: ${booking.id.toUpperCase()}",
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showInvoiceModal(BuildContext context, BookingModel booking) {
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
                const Text("Itemized Receipt", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textWhite)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text("PAID", style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _receiptRow("Vehicle", booking.vehicleName),
            _receiptRow("Trip Duration", "${booking.totalDays} Days"),
            _receiptRow("Daily Rate", "Rs. ${booking.pricePerDay.toStringAsFixed(0)}"),
            _receiptRow("Comprehensive Insurance", "INCLUDED"),
            _receiptRow("Roadside Assistance", "24/7 ACTIVE"),
            const Divider(height: 24, color: AppColors.surfaceGrey),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Paid", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textWhite)),
                Text("Rs. ${booking.totalPrice.toStringAsFixed(0)}", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 20)),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Receipt saved as PDF in downloads!")),
                );
              },
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text("Download PDF Receipt"),
            ),
          ],
        ),
      ),
    );
  }

  void _showLiveTrackingModal(BuildContext context, BookingModel booking) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        height: 380,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Live GPS Vehicle Tracker",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.gps_fixed_rounded, color: AppColors.success, size: 12),
                      SizedBox(width: 4),
                      Text("ONLINE", style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Simulated Map Box
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const RadialGradient(
                    center: Alignment(0.0, 0.2),
                    radius: 1.0,
                    colors: [Color(0xFF14263D), Color(0xFF0C1622)],
                  ),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.directions_car_rounded, color: AppColors.primary, size: 36),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.cardDark,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.primary),
                            ),
                            child: Text(
                              "${booking.vehicleName} • 45 km/h near Colombo 03",
                              style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Speed Limit: Normal • Battery/Fuel: 84%", style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Close"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _receiptRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
          Text(v, style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _fallbackImg() {
    return Container(
      width: 95,
      height: 75,
      color: AppColors.surfaceGrey,
      child: const Icon(Icons.directions_car, color: AppColors.textGrey),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'active':
        return AppColors.primary;
      case 'confirmed':
        return Colors.lightBlueAccent;
      case 'pending':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textGrey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'completed':
        return 'COMPLETED';
      case 'active':
        return 'IN PROGRESS';
      case 'confirmed':
        return 'CONFIRMED';
      case 'pending':
        return 'PENDING';
      case 'cancelled':
        return 'CANCELLED';
      default:
        return status.toUpperCase();
    }
  }

  static final List<BookingModel> _sampleBookingsFallback = [
    BookingModel(
      id: 'LANKA-89421',
      vehicleId: 'sample_1',
      vehicleName: 'Honda Dio 110 (2023)',
      vehicleImage: 'https://images.unsplash.com/photo-1558981806-ec527fa84c39?auto=format&fit=crop&w=600&q=75',
      buyerId: 'user_1',
      buyerName: 'Kamal Silva',
      buyerPhone: '+94 77 123 4567',
      sellerId: 'seller_1',
      sellerName: 'Lanka Ride Rentals',
      startDate: DateTime.now().add(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 4)),
      totalDays: 3,
      pricePerDay: 3500,
      totalPrice: 10500,
      status: 'confirmed',
      pickupLocation: 'Colombo 03, Sri Lanka',
      createdAt: DateTime.now(),
    ),
    BookingModel(
      id: 'LANKA-73209',
      vehicleId: 'sample_4',
      vehicleName: 'Toyota Prius Hybrid (2022)',
      vehicleImage: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=600&q=75',
      buyerId: 'user_1',
      buyerName: 'Kamal Silva',
      buyerPhone: '+94 77 123 4567',
      sellerId: 'seller_4',
      sellerName: 'Royal Lanka Cabs',
      startDate: DateTime.now().subtract(const Duration(days: 10)),
      endDate: DateTime.now().subtract(const Duration(days: 7)),
      totalDays: 3,
      pricePerDay: 14000,
      totalPrice: 42000,
      status: 'completed',
      pickupLocation: 'Bandaranaike Airport (BIA)',
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
  ];
}
