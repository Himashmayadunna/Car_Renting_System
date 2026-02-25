import 'package:flutter/material.dart';
import '../core/theme/colors.dart';
import '../models/vehicle_model.dart';
import '../screens/buyer/vehicle_detail_screen.dart';

class VehicleCard extends StatelessWidget {
  final VehicleModel vehicle;

  const VehicleCard({
    super.key,
    required this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VehicleDetailScreen(vehicle: vehicle),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    vehicle.images.isNotEmpty
                        ? Image.network(
                            vehicle.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: AppColors.surfaceGrey,
                              child: const Icon(Icons.directions_car, size: 40),
                            ),
                          )
                        : Container(
                            color: AppColors.surfaceGrey,
                            child: const Icon(Icons.directions_car, size: 40),
                          ),
                    // Type badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          vehicle.type,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      vehicle.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            color: AppColors.primary, size: 13),
                        const SizedBox(width: 3),
                        Text(
                          vehicle.rating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textGrey),
                        ),
                        const Spacer(),
                        Text(
                          vehicle.transmission,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textGrey),
                        ),
                      ],
                    ),
                    Text(
                      "\$${vehicle.pricePerDay.toStringAsFixed(0)}/day",
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
