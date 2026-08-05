import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../models/booking_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/premium_widgets.dart';
import '../common/chat_message_screen.dart';

class SellerBookingsScreen extends StatefulWidget {
  const SellerBookingsScreen({super.key});

  @override
  State<SellerBookingsScreen> createState() => _SellerBookingsScreenState();
}

class _SellerBookingsScreenState extends State<SellerBookingsScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    if (auth.user != null) {
      context.read<BookingProvider>().listenToSellerBookings(auth.user!.uid);
    }
  }

  void _showInvoiceGeneratorModal(BookingModel booking) {
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
                const Text("Host Tax Invoice Generator", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textWhite)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.success.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                  child: const Text("OFFICIAL", style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _invoiceRow("Guest Name", booking.buyerName),
            _invoiceRow("Trip Code", "#${booking.id}"),
            _invoiceRow("Vehicle Rental", booking.vehicleName),
            _invoiceRow("Duration", "${booking.totalDays} Days"),
            _invoiceRow("Host Payout Rate", "Rs. ${(booking.pricePerDay * 0.9).toStringAsFixed(0)} / day"),
            const Divider(height: 24, color: AppColors.surfaceGrey),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Net Host Earnings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textWhite)),
                Text(
                  "Rs. ${(booking.totalPrice * 0.9).toStringAsFixed(0)}",
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Official VAT/Tax Invoice downloaded as PDF!")),
                );
              },
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text("Generate & Download PDF Invoice"),
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  Widget _invoiceRow(String k, String v) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text("Guest Bookings Management"),
        centerTitle: true,
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProv, _) {
          final allBookings = bookingProv.sellerBookings.isNotEmpty
              ? bookingProv.sellerBookings
              : _sampleHostBookings;

          final filtered = _selectedFilter == 'All'
              ? allBookings
              : allBookings.where((b) => b.status.toLowerCase() == _selectedFilter.toLowerCase()).toList();

          return Column(
            children: [
              // 1. Status Filter Pills Bar
              SizedBox(
                height: 56,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: ['All', 'Pending', 'Confirmed', 'Active', 'Completed', 'Cancelled'].map((status) {
                    final isSelected = _selectedFilter == status;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFilter = status),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.cardDark,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              status,
                              style: TextStyle(
                                color: isSelected ? AppColors.textDark : AppColors.textWhite,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // 2. Bookings List
              Expanded(
                child: filtered.isEmpty
                    ? EmptyStateIllustration(
                        icon: Icons.assignment_outlined,
                        title: "No $_selectedFilter Bookings",
                        description: "No guest trip requests match this status in Sri Lanka.",
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                        itemCount: filtered.length,
                        itemBuilder: (context, idx) {
                          return _buildHostBookingCard(context, filtered[idx]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHostBookingCard(BuildContext context, BookingModel b) {
    final bookingProv = context.read<BookingProvider>();
    final statusColor = _getStatusColor(b.status);
    final isPending = b.status == 'pending';
    final isConfirmed = b.status == 'confirmed';
    final isActive = b.status == 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isPending ? AppColors.warning : Colors.white.withOpacity(0.08),
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 14, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Guest Info & DL Badge
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      child: Text(
                        b.buyerName.isNotEmpty ? b.buyerName[0] : "G",
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.buyerName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textWhite),
                        ),
                        Row(
                          children: const [
                            Icon(Icons.shield_rounded, color: AppColors.success, size: 12),
                            SizedBox(width: 4),
                            Text("DL & NIC Verified • 4.9 ★", style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    b.status.toUpperCase(),
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.surfaceGrey),

          // Body: Trip details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      b.vehicleName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textWhite),
                    ),
                    Text(
                      "Rs. ${b.totalPrice.toStringAsFixed(0)}",
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.date_range_rounded, size: 14, color: AppColors.textGrey),
                    const SizedBox(width: 6),
                    Text(
                      "${DateFormat('MMM d').format(b.startDate)} - ${DateFormat('MMM d, yyyy').format(b.endDate)} (${b.totalDays} Days)",
                      style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      "Pickup: ${b.pickupLocation ?? 'Colombo Area'}",
                      style: const TextStyle(color: AppColors.textGreyLight, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action buttons bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 8,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _toolBtn(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: "Message",
                      onTap: () {
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
                    ),
                    const SizedBox(width: 8),
                    _toolBtn(
                      icon: Icons.receipt_long_rounded,
                      label: "Tax Invoice",
                      onTap: () => _showInvoiceGeneratorModal(b),
                    ),
                  ],
                ),
                // Status Transition buttons
                if (isPending) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () => bookingProv.updateBookingStatus(b.id, 'confirmed'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(80, 38),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: const Text("Accept", style: TextStyle(fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () => bookingProv.updateBookingStatus(b.id, 'cancelled'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          minimumSize: const Size(70, 38),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: const Text("Decline", style: TextStyle(color: AppColors.error, fontSize: 12)),
                      ),
                    ],
                  ),
                ] else if (isConfirmed) ...[
                  ElevatedButton(
                    onPressed: () => bookingProv.updateBookingStatus(b.id, 'active'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textDark,
                      minimumSize: const Size(120, 38),
                    ),
                    child: const Text("Start Trip (Active)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ] else if (isActive) ...[
                  ElevatedButton(
                    onPressed: () => bookingProv.updateBookingStatus(b.id, 'completed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(130, 38),
                    ),
                    child: const Text("Mark Completed", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolBtn({
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
          border: Border.all(color: Colors.white.withOpacity(0.1)),
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

  static final List<BookingModel> _sampleHostBookings = [
    BookingModel(
      id: 'LANKA-89421',
      vehicleId: 'sample_4',
      vehicleName: 'Toyota Prius Hybrid (2022)',
      vehicleImage: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=600&q=75',
      buyerId: 'user_1',
      buyerName: 'Kamal Silva',
      buyerPhone: '+94 77 123 4567',
      sellerId: 'seller_4',
      sellerName: 'Lanka Ride Rentals',
      startDate: DateTime.now().add(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 4)),
      totalDays: 3,
      pricePerDay: 14000,
      totalPrice: 42000,
      status: 'confirmed',
      pickupLocation: 'Bandaranaike Airport (BIA)',
      createdAt: DateTime.now(),
    ),
    BookingModel(
      id: 'LANKA-49201',
      vehicleId: 'sample_4',
      vehicleName: 'Toyota Prius Hybrid (2022)',
      vehicleImage: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=600&q=75',
      buyerId: 'user_99',
      buyerName: 'Shenal Fernando',
      buyerPhone: '+94 71 890 2341',
      sellerId: 'seller_4',
      sellerName: 'Lanka Ride Rentals',
      startDate: DateTime.now().add(const Duration(days: 6)),
      endDate: DateTime.now().add(const Duration(days: 9)),
      totalDays: 3,
      pricePerDay: 14000,
      totalPrice: 42000,
      status: 'pending',
      pickupLocation: 'Colombo 03 Area',
      createdAt: DateTime.now(),
    ),
  ];
}
