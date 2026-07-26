import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/colors.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';
import 'trip_detail_screen.dart';

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
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: const [
              Tab(text: "Active & Upcoming"),
              Tab(text: "Trip History"),
              Tab(text: "Cancelled"),
            ],
          ),
        ),
        body: Consumer<BookingProvider>(
          builder: (context, bookingProvider, _) {
            final bookings = bookingProvider.buyerBookings;

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

  // 1. Active & Upcoming Tab
  Widget _buildActiveList(BuildContext context, List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.directions_car_outlined,
              size: 64,
              color: AppColors.textGrey,
            ),
            SizedBox(height: 16),
            Text(
              "No active or upcoming rentals",
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Explore cars on the home page to book your next drive!",
              style: TextStyle(color: AppColors.textGrey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _BookingCard(booking: booking, isHistory: false);
      },
    );
  }

  // 2. Trip History Tab
  Widget _buildTripHistoryList(BuildContext context, List<BookingModel> completedTrips) {
    if (completedTrips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.history_rounded,
              size: 64,
              color: AppColors.textGrey,
            ),
            SizedBox(height: 16),
            Text(
              "No completed trips yet",
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Your past rides and receipts will show up here after completing trips",
              style: TextStyle(color: AppColors.textGrey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    final totalTrips = completedTrips.length;
    final totalDaysRented = completedTrips.fold<int>(0, (sum, b) => sum + b.totalDays);
    final totalSpent = completedTrips.fold<double>(0.0, (sum, b) => sum + b.totalPrice);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        // Summary Stats Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF1E2638), Color(0xFF151B28)],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.insights_rounded, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Trip History Summary",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem("Total Trips", "$totalTrips"),
                  Container(width: 1, height: 30, color: AppColors.surfaceGrey),
                  _statItem("Days Rented", "$totalDaysRented Days"),
                  Container(width: 1, height: 30, color: AppColors.surfaceGrey),
                  _statItem("Total Spent", "\$${totalSpent.toStringAsFixed(0)}"),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        const Text(
          "Completed Rides",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textWhite,
          ),
        ),
        const SizedBox(height: 12),

        // List of Completed Trip Cards
        ...completedTrips.map((booking) => _BookingCard(booking: booking, isHistory: true)),

        const SizedBox(height: 80),
      ],
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textGrey,
          ),
        ),
      ],
    );
  }

  // 3. Cancelled Tab
  Widget _buildCancelledList(List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.cancel_outlined,
              size: 64,
              color: AppColors.textGrey,
            ),
            SizedBox(height: 16),
            Text(
              "No cancelled bookings",
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: bookings.length,
      itemBuilder: (context, index) => _BookingCard(booking: bookings[index], isHistory: false),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final bool isHistory;

  const _BookingCard({
    required this.booking,
    required this.isHistory,
  });

  Color get _statusColor {
    switch (booking.status) {
      case 'pending':
        return AppColors.warning;
      case 'confirmed':
        return Colors.blue;
      case 'active':
        return AppColors.primary;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TripDetailScreen(booking: booking),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Image, Name, Status Badge
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: booking.vehicleImage.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: booking.vehicleImage,
                          width: 70,
                          height: 52,
                          fit: BoxFit.cover,
                          memCacheWidth: 200,
                          errorWidget: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.vehicleName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textWhite,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Host: ${booking.sellerName}",
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking.statusDisplay,
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(color: AppColors.surfaceGrey, height: 1),
            const SizedBox(height: 14),

            // Date & Details Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textGrey),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          "${dateFormat.format(booking.startDate)} - ${dateFormat.format(booking.endDate)}",
                          style: const TextStyle(color: AppColors.textGreyLight, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "\$${booking.totalPrice.toStringAsFixed(0)}",
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ],
            ),

            // Rating Pill if completed
            if (isHistory && booking.rating != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.primary, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "Rated ${booking.rating!.toStringAsFixed(1)}",
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),

            // Action Buttons
            if (booking.status == 'active' || booking.status == 'confirmed') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _confirmCompleteTrip(context),
                  icon: const Icon(Icons.check_circle_rounded, color: AppColors.textDark, size: 18),
                  label: const Text(
                    "Complete Trip & Return Car",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textDark,
                    minimumSize: const Size(double.infinity, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ] else if (booking.status == 'pending') ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    context.read<BookingProvider>().cancelBooking(booking);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    minimumSize: const Size(double.infinity, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Cancel Booking"),
                ),
              ),
            ] else if (booking.status == 'completed') ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TripDetailScreen(booking: booking),
                          ),
                        );
                      },
                      icon: const Icon(Icons.receipt_long_rounded, size: 16, color: AppColors.primary),
                      label: const Text(
                        "View Digital Receipt",
                        style: TextStyle(fontSize: 12, color: AppColors.textWhite),
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.surfaceGrey),
                        minimumSize: const Size(double.infinity, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmCompleteTrip(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.directions_car_rounded, color: AppColors.primary),
            SizedBox(width: 10),
            Text("Complete Rental Trip?"),
          ],
        ),
        content: const Text(
          "Are you ready to return the vehicle and finish your trip? A digital receipt will be generated in your Trip History.",
          style: TextStyle(color: AppColors.textGreyLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Not Yet", style: TextStyle(color: AppColors.textGrey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final bookingProvider = context.read<BookingProvider>();
              await bookingProvider.completeBooking(booking);

              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TripDetailScreen(
                      booking: booking.copyWith(status: 'completed'),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textDark,
            ),
            child: const Text("Yes, Complete Trip"),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 70,
      height: 52,
      color: AppColors.surfaceGrey,
      child: const Icon(Icons.directions_car, size: 24, color: AppColors.textGrey),
    );
  }
}
