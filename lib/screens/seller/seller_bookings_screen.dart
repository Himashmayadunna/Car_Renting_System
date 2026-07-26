import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';

class SellerBookingsScreen extends StatelessWidget {
  const SellerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Booking Requests"),
          automaticallyImplyLeading: false,
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textGrey,
            tabs: const [
              Tab(text: "Pending"),
              Tab(text: "Active"),
              Tab(text: "History"),
            ],
          ),
        ),
        body: Consumer<BookingProvider>(
          builder: (context, bookingProv, _) {
            final bookings = bookingProv.sellerBookings;

            final pending = bookings
                .where((b) => b.status == 'pending' || b.status == 'confirmed')
                .toList();
            final active =
                bookings.where((b) => b.status == 'active').toList();
            final history = bookings
                .where(
                    (b) => b.status == 'completed' || b.status == 'cancelled')
                .toList();

            return TabBarView(
              children: [
                _buildList(context, pending, "No pending requests",
                    showActions: true),
                _buildList(context, active, "No active rentals",
                    showComplete: true),
                _buildList(context, history, "No booking history"),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<BookingModel> bookings,
    String emptyMsg, {
    bool showActions = false,
    bool showComplete = false,
  }) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined,
                size: 60, color: AppColors.textGrey.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(emptyMsg,
                style: const TextStyle(color: AppColors.textGrey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) => _SellerBookingCard(
        booking: bookings[index],
        showActions: showActions,
        showComplete: showComplete,
      ),
    );
  }
}

class _SellerBookingCard extends StatelessWidget {
  final BookingModel booking;
  final bool showActions;
  final bool showComplete;

  const _SellerBookingCard({
    required this.booking,
    this.showActions = false,
    this.showComplete = false,
  });

  Color get _statusColor {
    switch (booking.status) {
      case 'pending':
        return AppColors.warning;
      case 'confirmed':
        return Colors.blue;
      case 'active':
        return AppColors.success;
      case 'completed':
        return AppColors.primary;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle & status
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: booking.vehicleImage.isNotEmpty
                    ? Image.network(
                        booking.vehicleImage,
                        width: 55,
                        height: 42,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _placeholder(),
                      )
                    : _placeholder(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.vehicleName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(
                      "${dateFormat.format(booking.startDate)} - ${dateFormat.format(booking.endDate)} (${booking.totalDays} days)",
                      style: const TextStyle(
                          color: AppColors.textGrey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  booking.statusDisplay,
                  style: TextStyle(
                      color: _statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.surfaceGrey, height: 1),
          const SizedBox(height: 12),

          // Buyer info
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: AppColors.textGrey),
              const SizedBox(width: 6),
              Text(booking.buyerName,
                  style: const TextStyle(fontSize: 13)),
              const Spacer(),
              const Icon(Icons.phone_outlined, size: 16, color: AppColors.textGrey),
              const SizedBox(width: 6),
              Text(booking.buyerPhone,
                  style:
                      const TextStyle(fontSize: 13, color: AppColors.textGrey)),
            ],
          ),
          const SizedBox(height: 8),

          // Price
          Row(
            children: [
              Text(
                "\$${booking.pricePerDay.toStringAsFixed(0)}/day × ${booking.totalDays} days",
                style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
              ),
              const Spacer(),
              Text(
                "\$${booking.totalPrice.toStringAsFixed(0)}",
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),

          if (booking.notes != null && booking.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text("Note: ${booking.notes!}",
                style:
                    const TextStyle(color: AppColors.textGrey, fontSize: 12)),
          ],

          // Action buttons
          if (showActions && booking.status == 'pending') ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context
                          .read<BookingProvider>()
                          .cancelBooking(booking);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      minimumSize: const Size(double.infinity, 48),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Decline"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context
                          .read<BookingProvider>()
                          .confirmBooking(booking.id);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Confirm"),
                  ),
                ),
              ],
            ),
          ],

          if (showComplete && booking.status == 'active') ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context
                      .read<BookingProvider>()
                      .completeBooking(booking);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  minimumSize: const Size(double.infinity, 48),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Mark as Completed"),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 55,
      height: 42,
      color: AppColors.surfaceGrey,
      child: const Icon(Icons.directions_car, size: 20),
    );
  }
}
