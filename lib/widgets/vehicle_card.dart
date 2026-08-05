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

class _VehicleCardState extends State<VehicleCard>
    with SingleTickerProviderStateMixin {
  bool _isFavorite = true;
  late AnimationController _heartController;
  late Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _heartController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    _heartController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = widget.vehicle;
    final rating = vehicle.rating > 0 ? vehicle.rating : 4.9;
    final locationText = vehicle.location.isNotEmpty ? vehicle.location : 'Colombo, LK';

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
              color: Colors.white.withOpacity(0.06),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Expanded(
                flex: 12,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'vehicle_img_${vehicle.id}',
                        child: vehicle.images.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: vehicle.images.first,
                                fit: BoxFit.cover,
                                memCacheWidth: 500,
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
                      ),
                      // Top Left: Instant Badge
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.bolt_rounded,
                                color: AppColors.primary,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Instant',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textWhite,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Top Right: Favorite Heart
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: _toggleFavorite,
                          child: ScaleTransition(
                            scale: _heartScale,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.65),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: _isFavorite ? AppColors.primary : AppColors.textWhite,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Info Section
              Expanded(
                flex: 10,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title & Rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Hero(
                              tag: 'vehicle_name_${vehicle.id}',
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  vehicle.name.isNotEmpty ? vehicle.name : "${vehicle.brand} ${vehicle.model}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.textWhite,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: AppColors.primary, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: AppColors.textWhite,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      // Subtitle
                      Text(
                        "${vehicle.year} · ${vehicle.transmission} · ${vehicle.seats} seats",
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Location
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: AppColors.textGrey, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            "$locationText - 1.2 km",
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Price
                      Row(
                        children: [
                          Text(
                            'LKR ${vehicle.pricePerDay.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          const Text(
                            ' / day',
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 12,
                            ),
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
