import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../models/vehicle_model.dart';
import '../../models/booking_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/premium_widgets.dart';
import 'buyer_main_screen.dart';

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
  int _currentStep = 0; // 0: Dates, 1: Delivery, 2: Insurance, 3: Extras, 4: Summary

  // Step 1: Dates & Time
  DateTimeRange? _selectedDates;
  TimeOfDay _pickupTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _returnTime = const TimeOfDay(hour: 10, minute: 0);

  // Step 2: Location & Delivery
  bool _isHomeDelivery = false;
  final _deliveryAddressController = TextEditingController();

  // Step 3: Insurance Option
  // 0: Basic (Free), 1: Standard (+500/day), 2: Full Cover (+1200/day)
  int _selectedInsurance = 1;

  // Step 4: Extras
  bool _addGps = false;
  bool _addExtraDriver = false;
  bool _addChildSeat = false;
  bool _addWifi = false;
  bool _addPrepaidFuel = false;

  // Step 5: Promo & Notes
  final _promoController = TextEditingController();
  final _notesController = TextEditingController();
  double _discountPercentage = 0.0;
  bool _isPromoApplied = false;

  int get totalDays =>
      _selectedDates != null ? _selectedDates!.end.difference(_selectedDates!.start).inDays.clamp(1, 365) : 0;

  double get basePrice => totalDays * widget.vehicle.pricePerDay;

  double get insuranceCostPerDay {
    if (_selectedInsurance == 1) return 500.0;
    if (_selectedInsurance == 2) return 1200.0;
    return 0.0;
  }

  double get totalInsuranceCost => insuranceCostPerDay * totalDays;

  double get extrasCost {
    double total = 0.0;
    if (_addGps) total += 300.0 * totalDays;
    if (_addExtraDriver) total += 600.0 * totalDays;
    if (_addChildSeat) total += 500.0 * totalDays;
    if (_addWifi) total += 400.0 * totalDays;
    if (_addPrepaidFuel) total += 3500.0;
    return total;
  }

  double get deliveryFee => _isHomeDelivery ? 1500.0 : 0.0;

  double get subTotal => basePrice + totalInsuranceCost + extrasCost + deliveryFee;

  double get discountAmount => subTotal * (_discountPercentage / 100);

  double get grandTotal => subTotal - discountAmount;

  @override
  void initState() {
    super.initState();
    // Default: 3 days rental starting tomorrow
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    _selectedDates = DateTimeRange(start: tomorrow, end: tomorrow.add(const Duration(days: 3)));
  }

  @override
  void dispose() {
    _deliveryAddressController.dispose();
    _promoController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDates,
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

  void _applyPromoCode() {
    final code = _promoController.text.trim().toUpperCase();
    if (code == 'LANKA10' || code == 'RENTX10' || code == 'WELCOME10') {
      setState(() {
        _discountPercentage = 10.0;
        _isPromoApplied = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Promo Code applied! 10% OFF your rental."), backgroundColor: AppColors.success),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid Promo Code. Try 'LANKA10'"), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _confirmBooking() async {
    if (_selectedDates == null) return;

    final auth = context.read<AuthProvider>();
    final bookingProvider = context.read<BookingProvider>();

    if (auth.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to complete booking")),
      );
      return;
    }

    final pickupLocation = _isHomeDelivery
        ? "Home Delivery: ${_deliveryAddressController.text.isNotEmpty ? _deliveryAddressController.text : 'Colombo Area'}"
        : widget.vehicle.location;

    final booking = BookingModel(
      id: "RX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}",
      vehicleId: widget.vehicle.id,
      vehicleName: widget.vehicle.displayName,
      vehicleImage: widget.vehicle.images.isNotEmpty ? widget.vehicle.images.first : '',
      buyerId: auth.user!.uid,
      buyerName: auth.user!.name,
      buyerPhone: auth.user!.phone,
      sellerId: widget.vehicle.sellerId,
      sellerName: widget.vehicle.sellerName,
      startDate: _selectedDates!.start,
      endDate: _selectedDates!.end,
      totalDays: totalDays,
      pricePerDay: widget.vehicle.pricePerDay,
      totalPrice: grandTotal,
      pickupLocation: pickupLocation,
      notes: _notesController.text.isNotEmpty ? _notesController.text : "Ins: $_selectedInsurance, Delivery: $_isHomeDelivery",
      createdAt: DateTime.now(),
    );

    final success = await bookingProvider.createBooking(booking);

    if (success && mounted) {
      _showCelebrationDialog(booking.id);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to create booking. Please try again."),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showCelebrationDialog(String bookingCode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 48),
            ),
            const SizedBox(height: 20),
            const Text(
              "Booking Confirmed!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textWhite),
            ),
            const SizedBox(height: 8),
            Text(
              "Your trip request #$bookingCode has been sent to ${widget.vehicle.sellerName}.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
            ),
            const SizedBox(height: 20),
            // Simulated QR Check-in Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.qr_code_2_rounded, size: 44, color: AppColors.primary),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Digital Key & QR Check-in",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textWhite),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Show QR Code at pickup for instant inspection & release.",
                          style: TextStyle(color: AppColors.textGrey.withValues(alpha: 0.9), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const BuyerMainScreen(initialIndex: 1)),
                  (route) => false,
                );
              },
              child: const Text("View In My Bookings"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text("Customize Your Trip"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Step Progress Tracker
            _buildStepProgressBar(),
            const Divider(color: AppColors.surfaceGrey, height: 1),

            // 2. Main Step Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                child: _buildCurrentStepContent(),
              ),
            ),

            // 3. Footer Price bar with Next/Confirm Button
            _buildBottomNavFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepProgressBar() {
    final steps = ['Dates', 'Delivery', 'Insurance', 'Extras', 'Summary'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      color: AppColors.cardDark,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(steps.length, (idx) {
          final isActive = _currentStep == idx;
          final isCompleted = idx < _currentStep;
          return Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.success
                            : isActive
                                ? AppColors.primary
                                : AppColors.backgroundDark,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted
                              ? AppColors.success
                              : isActive
                                  ? AppColors.primary
                                  : AppColors.textGrey,
                        ),
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                            : Text(
                                "${idx + 1}",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isActive ? AppColors.textDark : AppColors.textGrey,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      steps[idx],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                        color: isActive ? AppColors.primary : AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
                if (idx < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 16, left: 4, right: 4),
                      color: idx < _currentStep ? AppColors.success : AppColors.surfaceGrey,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1Dates();
      case 1:
        return _buildStep2Delivery();
      case 2:
        return _buildStep3Insurance();
      case 3:
        return _buildStep4Extras();
      case 4:
      default:
        return _buildStep5Summary();
    }
  }

  // STEP 1: Dates & Time
  Widget _buildStep1Dates() {
    final startStr = _selectedDates != null ? DateFormat('E, MMM d, yyyy').format(_selectedDates!.start) : "Select date";
    final endStr = _selectedDates != null ? DateFormat('E, MMM d, yyyy').format(_selectedDates!.end) : "Select date";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "When is your trip?",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textWhite),
        ),
        const SizedBox(height: 6),
        const Text(
          "Choose your pickup and drop-off dates in Sri Lanka.",
          style: TextStyle(color: AppColors.textGrey, fontSize: 14),
        ),
        const SizedBox(height: 24),

        // Pick Dates Button Box
        GestureDetector(
          onTap: _pickDateRange,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.6)),
              boxShadow: [
                BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 16),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("PICKUP DATE", style: TextStyle(color: AppColors.textGrey, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(startStr, style: const TextStyle(color: AppColors.textWhite, fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("RETURN DATE", style: TextStyle(color: AppColors.textGrey, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(endStr, style: const TextStyle(color: AppColors.textWhite, fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Duration Info Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Duration", style: TextStyle(color: AppColors.textWhite, fontSize: 15, fontWeight: FontWeight.w600)),
              Text(
                "$totalDays Days",
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // STEP 2: Delivery & Location
  Widget _buildStep2Delivery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pickup & Delivery Method",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textWhite),
        ),
        const SizedBox(height: 6),
        const Text(
          "How would you like to receive the vehicle?",
          style: TextStyle(color: AppColors.textGrey, fontSize: 14),
        ),
        const SizedBox(height: 24),

        _deliveryOptionCard(
          title: "Self-Pickup from Owner",
          subtitle: "Pick up directly at ${widget.vehicle.location}",
          priceText: "FREE",
          isSelected: !_isHomeDelivery,
          onTap: () => setState(() => _isHomeDelivery = false),
        ),
        const SizedBox(height: 14),
        _deliveryOptionCard(
          title: "Doorstep / Airport Delivery",
          subtitle: "We deliver the vehicle to your hotel or Colombo Airport (BIA)",
          priceText: "+ Rs. 1,500",
          isSelected: _isHomeDelivery,
          onTap: () => setState(() => _isHomeDelivery = true),
        ),

        if (_isHomeDelivery) ...[
          const SizedBox(height: 24),
          const Text("Enter Delivery Address / Hotel Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _deliveryAddressController,
            decoration: const InputDecoration(
              hintText: "e.g. Shangri-La Colombo or Katunayake Airport Terminal 1",
            ),
          ),
        ],
      ],
    );
  }

  Widget _deliveryOptionCard({
    required String title,
    required String subtitle,
    required String priceText,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textWhite)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.backgroundDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                priceText,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 3: Insurance Options
  Widget _buildStep3Insurance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Choose Insurance Protection",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textWhite),
        ),
        const SizedBox(height: 6),
        const Text(
          "Travel peace of mind across Sri Lanka with comprehensive coverage.",
          style: TextStyle(color: AppColors.textGrey, fontSize: 14),
        ),
        const SizedBox(height: 24),

        _insuranceCard(
          index: 0,
          title: "Basic Liability (Free)",
          description: "Covers statutory third-party liability. High deductible applies for damages.",
          pricePerDay: "FREE",
          badgeText: null,
        ),
        const SizedBox(height: 14),
        _insuranceCard(
          index: 1,
          title: "Standard Protection",
          description: "Reduces damage deductible by 50% + Includes free 24/7 Roadside Assistance.",
          pricePerDay: "+ Rs. 500 / day",
          badgeText: "RECOMMENDED",
        ),
        const SizedBox(height: 14),
        _insuranceCard(
          index: 2,
          title: "Zero Excess Full Cover",
          description: "Zero deductible for collision, theft, tire, and glass damage. VIP hotline support.",
          pricePerDay: "+ Rs. 1,200 / day",
          badgeText: "MAX PEACE OF MIND",
        ),
      ],
    );
  }

  Widget _insuranceCard({
    required int index,
    required String title,
    required String description,
    required String pricePerDay,
    String? badgeText,
  }) {
    final isSelected = _selectedInsurance == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedInsurance = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                      color: isSelected ? AppColors.primary : AppColors.textGrey,
                    ),
                    const SizedBox(width: 10),
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textWhite)),
                  ],
                ),
                if (badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(color: AppColors.textGrey, fontSize: 12, height: 1.4)),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                pricePerDay,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 4: Extra Add-on Services
  Widget _buildStep4Extras() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Enhance Your Trip",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textWhite),
        ),
        const SizedBox(height: 6),
        const Text(
          "Add optional amenities for a smoother journey.",
          style: TextStyle(color: AppColors.textGrey, fontSize: 14),
        ),
        const SizedBox(height: 20),

        _extraSwitchTile(
          icon: Icons.gps_fixed_rounded,
          title: "GPS Navigation Device",
          subtitle: "Pre-loaded offline Sri Lanka maps",
          priceText: "Rs. 300 / day",
          value: _addGps,
          onChanged: (val) => setState(() => _addGps = val),
        ),
        _extraSwitchTile(
          icon: Icons.person_add_rounded,
          title: "Additional Verified Driver",
          subtitle: "Share driving duties legally across island tours",
          priceText: "Rs. 600 / day",
          value: _addExtraDriver,
          onChanged: (val) => setState(() => _addExtraDriver = val),
        ),
        _extraSwitchTile(
          icon: Icons.child_care_rounded,
          title: "Baby / Child Safety Seat",
          subtitle: "Sanitized ISOFIX child safety seat",
          priceText: "Rs. 500 / day",
          value: _addChildSeat,
          onChanged: (val) => setState(() => _addChildSeat = val),
        ),
        _extraSwitchTile(
          icon: Icons.wifi_rounded,
          title: "4G Mobile WiFi Hotspot",
          subtitle: "Unlimited Sri Lanka tourist data pocket router",
          priceText: "Rs. 400 / day",
          value: _addWifi,
          onChanged: (val) => setState(() => _addWifi = val),
        ),
        _extraSwitchTile(
          icon: Icons.local_gas_station_rounded,
          title: "Prepaid Full Fuel Tank",
          subtitle: "Return empty without searching for gas stations",
          priceText: "Rs. 3,500 (One-time)",
          value: _addPrepaidFuel,
          onChanged: (val) => setState(() => _addPrepaidFuel = val),
        ),
      ],
    );
  }

  Widget _extraSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String priceText,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: value ? AppColors.primary : Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppColors.textGrey, fontSize: 11)),
                const SizedBox(height: 4),
                Text(priceText, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // STEP 5: Final Summary & Coupon
  Widget _buildStep5Summary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Trip Summary & Payment",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textWhite),
        ),
        const SizedBox(height: 6),
        const Text(
          "Review your itemized invoice before sending the booking request.",
          style: TextStyle(color: AppColors.textGrey, fontSize: 14),
        ),
        const SizedBox(height: 20),

        // Vehicle mini card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: widget.vehicle.images.isNotEmpty
                    ? Image.network(widget.vehicle.images.first, width: 80, height: 65, fit: BoxFit.cover)
                    : Container(width: 80, height: 65, color: AppColors.surfaceGrey),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.vehicle.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textWhite)),
                    const SizedBox(height: 4),
                    Text("${widget.vehicle.location} • $totalDays Days", style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Promo Code Box
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _promoController,
                decoration: InputDecoration(
                  hintText: "Promo code (e.g. LANKA10)",
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  suffixIcon: _isPromoApplied ? const Icon(Icons.check_circle_rounded, color: AppColors.success) : null,
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _applyPromoCode,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(100, 48),
                backgroundColor: _isPromoApplied ? AppColors.success : AppColors.primary,
              ),
              child: Text(_isPromoApplied ? "APPLIED" : "APPLY"),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Itemized Cost Breakdown Table
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: [
              _invoiceRow("Rental Base ($totalDays days)", "Rs. ${basePrice.toStringAsFixed(0)}"),
              _invoiceRow("Insurance Coverage", "Rs. ${totalInsuranceCost.toStringAsFixed(0)}"),
              _invoiceRow("Extras & Amenities", "Rs. ${extrasCost.toStringAsFixed(0)}"),
              if (_isHomeDelivery) _invoiceRow("Doorstep Delivery Fee", "Rs. ${deliveryFee.toStringAsFixed(0)}"),
              if (_discountPercentage > 0)
                _invoiceRow("Promo Discount (${_discountPercentage.toStringAsFixed(0)}%)", "- Rs. ${discountAmount.toStringAsFixed(0)}", isDiscount: true),
              const Divider(height: 24, color: AppColors.surfaceGrey),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Grand Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textWhite)),
                  Text(
                    "Rs. ${grandTotal.toStringAsFixed(0)}",
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Refundable Security Deposit Note
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: const [
              Icon(Icons.lock_outline_rounded, color: AppColors.accentBlue, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Includes 100% Refundable Security Deposit protection. No hidden charges.",
                  style: TextStyle(color: AppColors.textGreyLight, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _invoiceRow(String label, String amount, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 14)),
          Text(
            amount,
            style: TextStyle(
              color: isDiscount ? AppColors.success : AppColors.textWhite,
              fontWeight: isDiscount ? FontWeight.bold : FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            OutlinedButton(
              onPressed: () => setState(() => _currentStep--),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(120, 52),
              ),
              child: const Text("Back"),
            )
          else
            const SizedBox.shrink(),
          ElevatedButton(
            onPressed: () {
              if (_currentStep < 4) {
                setState(() => _currentStep++);
              } else {
                _confirmBooking();
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: Size(_currentStep > 0 ? 180 : double.infinity, 52),
              backgroundColor: _currentStep == 4 ? AppColors.success : AppColors.primary,
              foregroundColor: _currentStep == 4 ? Colors.white : AppColors.textDark,
            ),
            child: Text(
              _currentStep == 4 ? "Confirm Booking • Rs. ${grandTotal.toStringAsFixed(0)}" : "Next Step →",
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
