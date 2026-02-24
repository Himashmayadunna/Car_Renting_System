import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/colors.dart';

class BookingScreen extends StatefulWidget {
  final String vehicleName;
  final double pricePerDay;

  const BookingScreen({
    super.key,
    required this.vehicleName,
    required this.pricePerDay,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTimeRange? selectedDates;
  int totalDays = 0;
  double totalPrice = 0;

  void pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDates = picked;
        totalDays =
            picked.end.difference(picked.start).inDays;
        totalPrice = totalDays * widget.pricePerDay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Booking")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.vehicleName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            const Text("Select Rental Dates"),
            const SizedBox(height: 10),

            GestureDetector(
              onTap: pickDateRange,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedDates == null
                          ? "Choose dates"
                          : "${DateFormat('MMM dd').format(selectedDates!.start)} - ${DateFormat('MMM dd').format(selectedDates!.end)}",
                    ),
                    const Icon(Icons.calendar_month),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            if (selectedDates != null) ...[
              Text("Total Days: $totalDays"),
              const SizedBox(height: 10),
              Text(
                "Total Price: \$${totalPrice.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 55),
          ),
          onPressed: selectedDates == null ? null : () {},
          child: const Text("Confirm Booking"),
        ),
      ),
    );
  }
}