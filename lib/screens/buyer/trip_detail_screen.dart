import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../core/theme/colors.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';

class TripDetailScreen extends StatefulWidget {
  final BookingModel booking;

  const TripDetailScreen({
    super.key,
    required this.booking,
  });

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  late double _currentRating;
  late TextEditingController _reviewController;
  bool _isSubmittingReview = false;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.booking.rating ?? 5.0;
    _reviewController = TextEditingController(text: widget.booking.review ?? '');
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Color get _statusColor {
    switch (widget.booking.status) {
      case 'completed':
        return AppColors.success;
      case 'active':
        return AppColors.primary;
      case 'confirmed':
        return Colors.blue;
      case 'pending':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final dateFormat = DateFormat('EEE, MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    final subtotal = booking.pricePerDay * booking.totalDays;
    final serviceFee = 500.0;
    final grandTotal = booking.totalPrice > 0 ? booking.totalPrice : subtotal + serviceFee;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text("Trip Details & Receipt"),
        backgroundColor: AppColors.backgroundDark,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textWhite),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Digital trip receipt link copied to clipboard!"),
                  backgroundColor: AppColors.accentBlue,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Vehicle Card & Status Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: booking.vehicleImage.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: booking.vehicleImage,
                            width: 85,
                            height: 65,
                            fit: BoxFit.cover,
                            memCacheWidth: 200,
                            errorWidget: (_, __, ___) => _placeholderImage(),
                          )
                        : _placeholderImage(),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.vehicleName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textWhite,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Rented from ${booking.sellerName}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: _statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                booking.status == 'completed'
                                    ? Icons.check_circle_rounded
                                    : Icons.directions_car_rounded,
                                size: 12,
                                color: _statusColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                booking.statusDisplay.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: _statusColor,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. Trip Timeline & Route Details
            const Text(
              "Rental Summary",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                children: [
                  // Pick-up details
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.circle,
                          color: AppColors.primary,
                          size: 10,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "PICK-UP LOCATION & DATE",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textGrey,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              booking.pickupLocation ?? 'Main Rental Hub',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textWhite,
                              ),
                            ),
                            Text(
                              "${dateFormat.format(booking.startDate)} • ${timeFormat.format(booking.startDate)}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textGreyLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Divider line
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 2,
                          height: 28,
                          color: AppColors.surfaceGrey,
                        ),
                      ],
                    ),
                  ),

                  // Drop-off details
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accentBlue.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: AppColors.accentBlue,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "RETURN LOCATION & DATE",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textGrey,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              booking.dropoffLocation ?? booking.pickupLocation ?? 'Main Rental Hub',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textWhite,
                              ),
                            ),
                            Text(
                              "${dateFormat.format(booking.endDate)} • ${timeFormat.format(booking.endDate)}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textGreyLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(color: AppColors.surfaceGrey, height: 1),
                  const SizedBox(height: 14),

                  // Duration chip
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.timer_outlined, color: AppColors.textGrey, size: 16),
                          SizedBox(width: 6),
                          Text(
                            "Total Duration",
                            style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                          ),
                        ],
                      ),
                      Text(
                        "${booking.totalDays} Days",
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3. Itemized Digital Receipt Card
            const Text(
              "Payment Receipt",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                children: [
                  _receiptRow(
                    "Vehicle Rental (${booking.totalDays} days × Rs. ${booking.pricePerDay.toStringAsFixed(0)})",
                    "Rs. ${subtotal.toStringAsFixed(0)}",
                  ),
                  const SizedBox(height: 10),
                  _receiptRow("Service & Insurance Protection", "Rs. ${serviceFee.toStringAsFixed(0)}"),
                  const SizedBox(height: 14),
                  const Divider(color: AppColors.surfaceGrey, height: 1),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Paid",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                      Text(
                        "Rs. ${grandTotal.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceGrey.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.credit_card_rounded, color: AppColors.textGrey, size: 18),
                            SizedBox(width: 8),
                            Text(
                              "Paid via Card (•••• 4242)",
                              style: TextStyle(color: AppColors.textWhite, fontSize: 12),
                            ),
                          ],
                        ),
                        Text(
                          "#TRIP-${booking.id.substring(0, booking.id.length > 6 ? 6 : booking.id.length)}",
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 4. Rate & Review Section (For Completed Trips)
            if (booking.status == 'completed') ...[
              const Text(
                "Rate Your Experience",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Column(
                  children: [
                    const Text(
                      "How was your trip with this vehicle?",
                      style: TextStyle(color: AppColors.textGreyLight, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    RatingBar.builder(
                      initialRating: _currentRating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star_rounded,
                        color: AppColors.primary,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          _currentRating = rating;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _reviewController,
                      maxLines: 3,
                      style: const TextStyle(color: AppColors.textWhite, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Write a short review for this car (optional)...",
                        fillColor: AppColors.surfaceGrey.withValues(alpha: 0.5),
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmittingReview
                            ? null
                            : () async {
                                setState(() => _isSubmittingReview = true);
                                final updatedBooking = booking.copyWith(
                                  rating: _currentRating,
                                  review: _reviewController.text.trim(),
                                );
                                final success = await context
                                    .read<BookingProvider>()
                                    .updateBookingReview(updatedBooking);

                                if (mounted) {
                                  setState(() => _isSubmittingReview = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? "Thank you for rating your trip!"
                                            : "Review saved successfully!",
                                      ),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textDark,
                          minimumSize: const Size(double.infinity, 50),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isSubmittingReview
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.textDark,
                                ),
                              )
                            : const Text("Submit Review"),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 5. Download Receipt Action Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Downloading PDF receipt to your device..."),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                icon: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary),
                label: const Text("Download PDF Receipt"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textWhite,
                  side: const BorderSide(color: AppColors.primary),
                  minimumSize: const Size(double.infinity, 54),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 85,
      height: 65,
      color: AppColors.surfaceGrey,
      child: const Icon(Icons.directions_car, size: 30, color: AppColors.textGrey),
    );
  }
}
