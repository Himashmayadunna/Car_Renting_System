import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../models/vehicle_model.dart';
import '../../providers/vehicle_provider.dart';
import '../../widgets/vehicle_card.dart';
import 'vehicle_detail_screen.dart';

class SearchExploreScreen extends StatefulWidget {
  final String initialQuery;
  const SearchExploreScreen({super.key, this.initialQuery = ''});

  @override
  State<SearchExploreScreen> createState() => _SearchExploreScreenState();
}

class _SearchExploreScreenState extends State<SearchExploreScreen> {
  late TextEditingController _searchController;
  String _searchQuery = '';
  bool _isMapView = false;
  String _selectedSort = 'Recommended';
  VehicleModel? _selectedMapVehicle;

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialQuery;
    _searchController = TextEditingController(text: _searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showVoiceSearchModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: const Icon(Icons.mic_rounded, color: AppColors.primary, size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                "Listening...",
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Say a Sri Lanka city or vehicle brand (e.g. 'Honda Dio in Colombo')",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGrey, fontSize: 13),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _voiceSampleChip("Honda Dio", ctx),
                  _voiceSampleChip("Tuk Tuk Negombo", ctx),
                  _voiceSampleChip("Prius Colombo", ctx),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _voiceSampleChip(String sample, BuildContext ctx) {
    return GestureDetector(
      onTap: () {
        _searchController.text = sample;
        setState(() => _searchQuery = sample.toLowerCase());
        Navigator.pop(ctx);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.backgroundDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Text(
          '"$sample"',
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vehicleProvider = context.watch<VehicleProvider>();
    final allVehicles = vehicleProvider.rawVehicles;

    // Filter by query and category
    List<VehicleModel> filtered = allVehicles.where((v) {
      final matchesQuery = _searchQuery.isEmpty ||
          v.name.toLowerCase().contains(_searchQuery) ||
          v.brand.toLowerCase().contains(_searchQuery) ||
          v.model.toLowerCase().contains(_searchQuery) ||
          v.location.toLowerCase().contains(_searchQuery) ||
          v.type.toLowerCase().contains(_searchQuery);

      final matchesType = vehicleProvider.selectedType == 'All' ||
          v.type.toLowerCase() == vehicleProvider.selectedType.toLowerCase();

      return matchesQuery && matchesType;
    }).toList();

    // Apply sorting
    if (_selectedSort == 'Price: Low to High') {
      filtered.sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
    } else if (_selectedSort == 'Price: High to Low') {
      filtered.sort((a, b) => b.pricePerDay.compareTo(a.pricePerDay));
    } else if (_selectedSort == 'Rating') {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Back button, Search input, Voice button, Map/List Toggle
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textWhite),
                  ),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          const Icon(Icons.search_rounded, color: AppColors.textGrey, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) {
                                setState(() => _searchQuery = val.trim().toLowerCase());
                              },
                              style: const TextStyle(color: AppColors.textWhite, fontSize: 14),
                              decoration: const InputDecoration(
                                hintText: "Search city, model, or category...",
                                hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 13),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                fillColor: Colors.transparent,
                                filled: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                              icon: const Icon(Icons.close, color: AppColors.textGrey, size: 16),
                            ),
                          IconButton(
                            onPressed: _showVoiceSearchModal,
                            icon: const Icon(Icons.mic_none_rounded, color: AppColors.primary, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Map / List Toggle Button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isMapView = !_isMapView;
                        _selectedMapVehicle = null;
                      });
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _isMapView ? AppColors.primary : AppColors.cardDark,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _isMapView ? AppColors.primary : Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Icon(
                        _isMapView ? Icons.format_list_bulleted_rounded : Icons.map_outlined,
                        color: _isMapView ? AppColors.textDark : AppColors.textWhite,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Filter & Sort chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _sortDropdown(),
                  const SizedBox(width: 8),
                  _categoryChip("All", vehicleProvider),
                  _categoryChip("Bike", vehicleProvider),
                  _categoryChip("Three-Wheel", vehicleProvider),
                  _categoryChip("Car", vehicleProvider),
                  _categoryChip("Van", vehicleProvider),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Content area: Map View vs List Grid
            Expanded(
              child: _isMapView
                  ? _buildInteractiveMapView(filtered)
                  : _buildListGridView(filtered),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sortDropdown() {
    return PopupMenuButton<String>(
      initialValue: _selectedSort,
      onSelected: (val) {
        setState(() => _selectedSort = val);
      },
      color: AppColors.cardDark,
      itemBuilder: (ctx) => [
        const PopupMenuItem(value: 'Recommended', child: Text("Sort: Recommended")),
        const PopupMenuItem(value: 'Price: Low to High', child: Text("Price: Low to High")),
        const PopupMenuItem(value: 'Price: High to Low', child: Text("Price: High to Low")),
        const PopupMenuItem(value: 'Rating', child: Text("Top Rated First")),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.sort_rounded, color: AppColors.primary, size: 16),
            const SizedBox(width: 6),
            Text(
              _selectedSort,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _categoryChip(String label, VehicleProvider prov) {
    final isSelected = prov.selectedType == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          prov.setType(label);
        },
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.cardDark,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.textDark : AppColors.textWhite,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildListGridView(List<VehicleModel> vehicles) {
    if (vehicles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 64, color: AppColors.textGrey),
            const SizedBox(height: 16),
            const Text(
              "No vehicles match your search",
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Try searching a different city or resetting filters",
              style: TextStyle(color: AppColors.textGrey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        return VehicleCard(vehicle: vehicles[index]);
      },
    );
  }

  Widget _buildInteractiveMapView(List<VehicleModel> vehicles) {
    return Stack(
      children: [
        // Simulated Sri Lanka Interactive Map background
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, 0.1),
              radius: 1.2,
              colors: [
                Color(0xFF14243A),
                Color(0xFF0D1826),
                Color(0xFF09101A),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Grid overlay pattern
              Positioned.fill(
                child: CustomPaint(
                  painter: _MapGridPainter(),
                ),
              ),
              // Map label
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.location_on, color: AppColors.primary, size: 14),
                      SizedBox(width: 4),
                      Text(
                        "Sri Lanka Live Map View • 14 Available Nearby",
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              // Price Marker Pins across Sri Lanka (Colombo, Negombo, Galle, Kandy, Ella)
              ..._buildMapMarkers(vehicles),
            ],
          ),
        ),
        // Selected Vehicle Bottom Preview Sheet
        if (_selectedMapVehicle != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: _buildMapPreviewCard(_selectedMapVehicle!),
          ),
      ],
    );
  }

  List<Widget> _buildMapMarkers(List<VehicleModel> vehicles) {
    final markerPositions = [
      const Offset(0.35, 0.45), // Colombo
      const Offset(0.32, 0.36), // Negombo
      const Offset(0.48, 0.42), // Kandy
      const Offset(0.40, 0.65), // Galle
      const Offset(0.60, 0.50), // Ella
      const Offset(0.55, 0.38), // Sigiriya
    ];

    return List.generate(vehicles.length.clamp(0, markerPositions.length), (index) {
      final v = vehicles[index];
      final pos = markerPositions[index];

      final isSelected = _selectedMapVehicle?.id == v.id;

      return Align(
        alignment: Alignment(pos.dx * 2 - 1, pos.dy * 2 - 1),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedMapVehicle = v;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.cardDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.white : AppColors.primary,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isSelected ? AppColors.primary : Colors.black).withValues(alpha: 0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  v.type == 'Bike'
                      ? Icons.two_wheeler_rounded
                      : v.type == 'Three-Wheel'
                          ? Icons.electric_rickshaw_rounded
                          : Icons.directions_car_rounded,
                  size: 14,
                  color: isSelected ? AppColors.textDark : AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  "Rs. ${v.pricePerDay.toStringAsFixed(0)}",
                  style: TextStyle(
                    color: isSelected ? AppColors.textDark : AppColors.textWhite,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildMapPreviewCard(VehicleModel v) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VehicleDetailScreen(vehicle: v),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x99000000),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: v.images.isNotEmpty
                  ? Image.network(
                      v.images.first,
                      width: 85,
                      height: 75,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallbackImg(),
                    )
                  : _fallbackImg(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    v.displayName,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.primary, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        v.rating > 0 ? v.rating.toStringAsFixed(1) : "4.9",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "•  ${v.location}",
                        style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rs. ${v.pricePerDay.toStringAsFixed(0)}/day",
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const Text(
                        "Tap to book →",
                        style: TextStyle(
                          color: AppColors.textGreyLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackImg() {
    return Container(
      width: 85,
      height: 75,
      color: AppColors.surfaceGrey,
      child: const Icon(Icons.directions_car, color: AppColors.textGrey),
    );
  }

}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1.0;
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
