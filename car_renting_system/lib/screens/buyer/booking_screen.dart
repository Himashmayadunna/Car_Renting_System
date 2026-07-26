import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../models/vehicle_model.dart';
import '../../models/booking_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';

class BookingScreen extends StatefulWidget {
  final VehicleModel vehicle;

  const BookingScreen({
    super.key,
    required this.vehicle,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTimeRange? _selectedDates;
  final _notesController = TextEditingController();
  final _pickupController = TextEditingController();

  int get totalDays =>
      _selectedDates != null
          ? _selectedDates!.end.difference(_selectedDates!.start).inDays
          : 0;

  double get totalPrice => totalDays * widget.vehicle.pricePerDay;

  @override
  void dispose() {
    _notesController.dispose();
    _pickupController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.textDark,
              surface: AppColors.cardDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDates = picked);
    }
  }

  Future<void> _confirmBooking() async {
    if (_selectedDates == null) return;

    final auth = context.read<AuthProvider>();
    final bookingProvider = context.read<BookingProvider>();

    if (auth.user == null) return;

    final booking = BookingModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      vehicleId: widget.vehicle.id,
      vehicleName: widget.vehicle.displayName,
      vehicleImage:
          widget.vehicle.images.isNotEmpty ? widget.vehicle.images.first : '',
      buyerId: auth.user!.uid,
      buyerName: auth.user!.name,
      buyerPhone: auth.user!.phone,
      sellerId: widget.vehicle.sellerId,
      sellerName: widget.vehicle.sellerName,
      startDate: _selectedDates!.start,
      endDate: _selectedDates!.end,
      totalDays: totalDays,
      pricePerDay: widget.vehicle.pricePerDay,
      totalPrice: totalPrice,
      pickupLocation: _pickupController.text.isNotEmpty
          ? _pickupController.text
          : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      createdAt: DateTime.now(),
    );

    final success = await bookingProvider.createBooking(booking);

    if (success && mounted) {
      _showSuccessDialog();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to create booking. Please try again."),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.check, color: AppColors.success, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              "Booking Confirmed!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Your booking request has been sent to the vehicle owner.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGrey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // dialog
                Navigator.pop(context); // booking screen
                Navigator.pop(context); // detail screen
              },
              child: const Text("Back to Home"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Vehicle"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle summary card
            _buildVehicleSummary(),
            const SizedBox(height: 24),

            // Date selection
            const Text("Rental Period",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _buildDateSelector(),
            const SizedBox(height: 24),

            // Pickup location
            const Text("Pickup Location (Optional)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            TextField(
              controller: _pickupController,
              decoration: const InputDecoration(
                hintText: "Enter pickup address",
                prefixIcon: Icon(Icons.location_on_outlined,
                    color: AppColors.textGrey, size: 20),
              ),
            ),
            const SizedBox(height: 24),

            // Notes
            const Text("Notes (Optional)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Any special requirements...",
              ),
            ),
            const SizedBox(height: 24),

            // Price breakdown
            if (_selectedDates != null) _buildPriceBreakdown(),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildConfirmButton(),
    );
  }

  Widget _buildVehicleSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: widget.vehicle.images.isNotEmpty
                ? Image.network(
                    widget.vehicle.images.first,
                    width: 80,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 80,
                      height: 60,
                      color: AppColors.surfaceGrey,
                      child: const Icon(Icons.directions_car, size: 30),
                    ),
                  )
                : Container(
                    width: 80,
                    height: 60,
                    color: AppColors.surfaceGrey,
                    child: const Icon(Icons.directions_car, size: 30),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.vehicle.displayName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                Text(
                  "\$${widget.vehicle.pricePerDay.toStringAsFixed(0)}/day • ${widget.vehicle.type}",
                  style: const TextStyle(
                      color: AppColors.primary, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: _pickDateRange,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.calendar_month,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedDates == null
                        ? "Select dates"
                        : "${DateFormat('MMM dd, yyyy').format(_selectedDates!.start)} - ${DateFormat('MMM dd, yyyy').format(_selectedDates!.end)}",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: _selectedDates == null
                          ? AppColors.textGrey
                          : AppColors.textWhite,
                    ),
                  ),
                  if (_selectedDates != null)
                    Text(
                      "$totalDays ${totalDays == 1 ? 'day' : 'days'}",
                      style: const TextStyle(
                          color: AppColors.primary, fontSize: 12),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildPriceRow(
            "Price per day",
            "\$${widget.vehicle.pricePerDay.toStringAsFixed(2)}",
          ),
          const SizedBox(height: 12),
          _buildPriceRow("Number of days", "$totalDays"),
          if (widget.vehicle.hasInsurance) ...[
            const SizedBox(height: 12),
            _buildPriceRow("Insurance", "Included", isGreen: true),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.surfaceGrey),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(
                "\$${totalPrice.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textGrey)),
        Text(
          value,
          style: TextStyle(
            color: isGreen ? AppColors.success : AppColors.textWhite,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, _) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: const BoxDecoration(
            color: AppColors.backgroundDark,
            border: Border(
                top: BorderSide(color: AppColors.surfaceGrey, width: 0.5)),
          ),
          child: SafeArea(
            top: false,
            child: ElevatedButton(
              onPressed: _selectedDates == null || bookingProvider.isLoading
                  ? null
                  : _confirmBooking,
              child: bookingProvider.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      _selectedDates == null
                          ? "Select Dates to Continue"
                          : "Confirm Booking — \$${totalPrice.toStringAsFixed(0)}",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
            ),
          ),
        );
      },
    );
  }
}
