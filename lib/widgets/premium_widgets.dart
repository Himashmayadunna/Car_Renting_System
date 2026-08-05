import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/colors.dart';

/// 1. Glassmorphic Container with blur and subtle border
class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? backgroundColor;
  final double blur;
  final Border? border;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.backgroundColor,
    this.blur = 12,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.cardDark.withOpacity(0.75),
              borderRadius: BorderRadius.circular(borderRadius),
              border: border ??
                  Border.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 1.2,
                  ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 2. Shimmer Skeleton Loader for modern animated loading states
class ShimmerSkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerSkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 16,
  });

  @override
  State<ShimmerSkeletonLoader> createState() => _ShimmerSkeletonLoaderState();
}

class _ShimmerSkeletonLoaderState extends State<ShimmerSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _animation = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [
                AppColors.cardDark,
                AppColors.surfaceGrey.withOpacity(0.6),
                AppColors.cardDark,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// 3. Premium Empty State Illustration Widget
class EmptyStateIllustration extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyStateIllustration({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: onButtonPressed,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text(buttonText!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textDark,
                  minimumSize: const Size(200, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 4. Verified Badge and Tag items
class VerifiedBadge extends StatelessWidget {
  final String text;
  final bool isSeller;

  const VerifiedBadge({
    super.key,
    this.text = 'Verified',
    this.isSeller = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified_rounded,
            color: AppColors.success,
            size: 13,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.success,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class LuxuryTag extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const LuxuryTag({
    super.key,
    required this.label,
    this.color = AppColors.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// 5. Emergency SOS & Roadside Assistance trigger button
class EmergencySosButton extends StatelessWidget {
  const EmergencySosButton({super.key});

  void _showSosDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.sos_rounded, color: Colors.redAccent, size: 28),
            ),
            const SizedBox(width: 12),
            const Text(
              "24/7 Roadside SOS",
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textWhite),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "In case of a breakdown, accident, or emergency during your Sri Lanka rental trip, connect immediately with our rapid dispatch network.",
              style: TextStyle(color: AppColors.textGrey, height: 1.4, fontSize: 13),
            ),
            const SizedBox(height: 18),
            _sosContactRow(Icons.phone_in_talk, "Emergency Police & Ambulance", "119 / 1990"),
            const SizedBox(height: 12),
            _sosContactRow(Icons.car_crash_rounded, "RentX Roadside Assistance", "+94 11 234 5678"),
            const SizedBox(height: 12),
            _sosContactRow(Icons.health_and_safety_rounded, "Tourist Police Hotline", "1912"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close", style: TextStyle(color: AppColors.textGrey)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Calling RentX 24/7 Roadside Dispatch Team..."),
                  backgroundColor: AppColors.accentBlue,
                ),
              );
            },
            icon: const Icon(Icons.call_rounded, size: 16),
            label: const Text("Call Hotline"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sosContactRow(IconData icon, String title, String number) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  number,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSosDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.sos_rounded, color: Colors.redAccent, size: 18),
            SizedBox(width: 4),
            Text(
              "SOS",
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 6. AI Vehicle Recommendation Assistant Modal
class AiRecommendationModal extends StatelessWidget {
  const AiRecommendationModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "RentX AI Recommender",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: AppColors.textGrey),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "What kind of trip in Sri Lanka are you planning?",
            style: TextStyle(color: AppColors.textGreyLight, fontSize: 14),
          ),
          const SizedBox(height: 16),
          _aiOption(
            context,
            "Hill Country Adventure (Kandy - Ella - Nuwara Eliya)",
            "We recommend automatic sedans or high-clearance SUVs with strong brakes.",
            "SUZUKI Alto 800 or Toyota Prius",
          ),
          const SizedBox(height: 12),
          _aiOption(
            context,
            "South Coast Beach Roadtrip (Galle - Mirissa - Tangalle)",
            "Experience island vibes with an authentic Sri Lankan Tuk-Tuk or open scooter.",
            "Honda Dio 110 or Bajaj RE 205",
          ),
          const SizedBox(height: 12),
          _aiOption(
            context,
            "Group Tour & Family Airport Transfer",
            "Maximum comfort with dual AC and extra luggage capacity.",
            "Toyota KDH Super GL Van",
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _aiOption(
    BuildContext context,
    String title,
    String description,
    String suggestedVehicle,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("AI Recommendation selected: $suggestedVehicle! Showing matches."),
            backgroundColor: AppColors.accentBlue,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.backgroundDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 14),
                const SizedBox(width: 6),
                Text(
                  "Top match: $suggestedVehicle",
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
