import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme/colors.dart';
import '../models/vehicle_model.dart';
import '../screens/buyer/vehicle_detail_screen.dart';

class VehicleCard extends StatefulWidget {
  final VehicleModel vehicle;

  const VehicleCard({
    super.key,
    required this.vehicle,
  });

  @override
  State<VehicleCard> createState() => _VehicleCardState();
}

class _VehicleCardState extends State<VehicleCard> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final vehicle = widget.vehicle;
    final rating = vehicle.rating > 0 ? vehicle.rating : 4.9;
    final locationText = vehicle.location.isNotEmpty ? vehicle.location : '1.2 km';

    return RepaintBoundary(
      child: GestureDetector(
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
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section with Badges
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      vehicle.images.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: vehicle.images.first,
                              fit: BoxFit.cover,
                              memCacheWidth: 400,
                              placeholder: (context, url) => Container(
                                color: AppColors.surfaceGrey,
                                child: const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: AppColors.surfaceGrey,
                                child: const Icon(
                                  Icons.directions_car,
                                  size: 48,
                                  color: AppColors.textGrey,
                                ),
                              ),
                            )
                          : Container(
                              color: AppColors.surfaceGrey,
                              child: const Icon(
                                Icons.directions_car,
                                size: 48,
                                color: AppColors.textGrey,
                              ),
                            ),
                      // Dark Gradient overlay at bottom of image for readability
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Color(0x1A000000),
                                Color(0x99000000),
                              ],
                              stops: [0.4, 0.7, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // Top Left Rating Badge (★ 4.9)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: AppColors.primary,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textWhite,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Top Right Heart Button
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isFavorite = !_isFavorite;
                            });
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: _isFavorite ? Colors.redAccent : AppColors.textWhite,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      // Bottom Left Distance/Location Badge
                      Positioned(
                        bottom: 8,
                        left: 10,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: AppColors.textGrey,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              locationText,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textGreyLight,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Info Section
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Brand name in uppercase
                          Text(
                            vehicle.brand.isNotEmpty
                                ? vehicle.brand.toUpperCase()
                                : 'CAR RENTAL',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textGrey,
                              letterSpacing: 0.8,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          // Model name in bold
                          Text(
                            vehicle.model.isNotEmpty
                                ? vehicle.model
                                : vehicle.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textWhite,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      // Specs line + Price per day row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Specs icons (Transmission / Type)
                          Row(
                            children: [
                              const Icon(
                                Icons.speed_outlined,
                                size: 13,
                                color: AppColors.textGrey,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                vehicle.transmission,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ],
                          ),
                          // Price tag
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${vehicle.pricePerDay.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  height: 1.1,
                                ),
                              ),
                              const Text(
                                'per day',
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
