import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Bookings"),
          automaticallyImplyLeading: false,
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textGrey,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: "Pending"),
              Tab(text: "Active"),
              Tab(text: "Completed"),
              Tab(text: "Cancelled"),
            ],
          ),
        ),
        body: Consumer<BookingProvider>(
          builder: (context, bookingProvider, _) {
            final bookings = bookingProvider.buyerBookings;

            final pending = bookings
                .where((b) => b.status == 'pending' || b.status == 'confirmed')
                .toList();
            final active =
                bookings.where((b) => b.status == 'active').toList();
            final completed =
                bookings.where((b) => b.status == 'completed').toList();
            final cancelled =
                bookings.where((b) => b.status == 'cancelled').toList();

            return TabBarView(
              children: [
                _buildBookingList(pending, "No pending bookings"),
                _buildBookingList(active, "No active rentals"),
                _buildBookingList(completed, "No completed bookings"),
                _buildBookingList(cancelled, "No cancelled bookings"),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookingList(List<BookingModel> bookings, String emptyMessage) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 60, color: AppColors.textGrey.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(emptyMessage,
                style: const TextStyle(color: AppColors.textGrey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) => _BookingCard(booking: bookings[index]),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  const _BookingCard({required this.booking});

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
          // Header row with vehicle and status
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: booking.vehicleImage.isNotEmpty
                    ? Image.network(
                        booking.vehicleImage,
                        width: 60,
                        height: 45,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _imagePlaceholder(),
                      )
                    : _imagePlaceholder(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.vehicleName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    Text("Seller: ${booking.sellerName}",
                        style: const TextStyle(
                            color: AppColors.textGrey, fontSize: 12)),
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
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.surfaceGrey, height: 1),
          const SizedBox(height: 14),
          // Details
          Row(
            children: [
              _infoChip(Icons.calendar_today,
                  "${dateFormat.format(booking.startDate)} - ${dateFormat.format(booking.endDate)}"),
              const SizedBox(width: 16),
              _infoChip(Icons.schedule, "${booking.totalDays} days"),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (booking.pickupLocation != null)
                Expanded(
                  child: _infoChip(
                      Icons.location_on_outlined, booking.pickupLocation!),
                ),
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
          // Cancel button for pending bookings
          if (booking.status == 'pending' || booking.status == 'confirmed') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  context.read<BookingProvider>().cancelBooking(booking);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                child: const Text("Cancel Booking"),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 60,
      height: 45,
      color: AppColors.surfaceGrey,
      child: const Icon(Icons.directions_car, size: 22),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textGrey),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
