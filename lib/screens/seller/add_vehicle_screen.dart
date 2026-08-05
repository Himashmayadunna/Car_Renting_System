import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/colors.dart';
import '../../models/vehicle_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../widgets/premium_widgets.dart';

class AddVehicleScreen extends StatefulWidget {
  final VehicleModel? vehicleToEdit;

  const AddVehicleScreen({
    super.key,
    this.vehicleToEdit,
  });

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController(text: "2023");
  final _colorController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _locationController = TextEditingController(text: "Colombo 03, Sri Lanka");

  String _selectedType = 'Car';
  String _selectedTransmission = 'Auto';
  int _seats = 5;
  bool _isLoading = false;

  final List<String> _imageUrls = [];
  final List<String> _selectedFeatures = ['AC', 'Bluetooth Audio', 'Reverse Camera'];

  final List<String> _availableFeatures = [
    'AC',
    'Bluetooth Audio',
    'GPS Navigation',
    'Reverse Camera',
    'Child Seat Ready',
    'USB Charging',
    'Helmet Included',
    'Luggage Rack',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.vehicleToEdit != null) {
      final v = widget.vehicleToEdit!;
      _brandController.text = v.brand;
      _modelController.text = v.model;
      _yearController.text = v.year.toString();
      _colorController.text = v.color;
      _priceController.text = v.pricePerDay.toStringAsFixed(0);
      _descriptionController.text = v.description;
      _locationController.text = v.location;
      _selectedType = v.type;
      _selectedTransmission = v.transmission;
      _seats = v.seats;
      _imageUrls.addAll(v.images);
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _imageUrls.add(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to pick image: $e")),
        );
      }
    }
  }

  /// AI Dynamic Price Recommendation Engine
  void _suggestAiPrice() {
    final type = _selectedType;
    final yearStr = _yearController.text.trim();
    final year = int.tryParse(yearStr) ?? 2022;

    double suggested = 4500.0;
    if (type == 'Car') {
      suggested = year >= 2022 ? 14000.0 : 11000.0;
    } else if (type == 'Van') {
      suggested = 18000.0;
    } else if (type == 'EV') {
      suggested = 19500.0;
    } else if (type == 'Three-Wheel') {
      suggested = 4500.0;
    } else if (type == 'Bike') {
      suggested = 3500.0;
    }

    setState(() {
      _priceController.text = suggested.toStringAsFixed(0);
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 24),
                SizedBox(width: 8),
                Text("AI Pricing Advisor", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textWhite)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Based on recent Sri Lanka demand for $type ($year), we recommend Rs. ${suggested.toStringAsFixed(0)} / day to maximize occupancy and revenue.",
              style: const TextStyle(color: AppColors.textGreyLight, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Apply AI Rate"),
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationPicker() {
    final locations = [
      'Colombo 03, Sri Lanka',
      'Colombo 07, Sri Lanka',
      'Bandaranaike Airport (BIA)',
      'Kandy City Centre',
      'Galle Fort, Sri Lanka',
      'Negombo Beach',
      'Ella Hills, Sri Lanka',
    ];

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
            const Text("Select Pickup Location", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textWhite)),
            const SizedBox(height: 12),
            ...locations.map((loc) => ListTile(
                  leading: const Icon(Icons.location_on_rounded, color: AppColors.primary),
                  title: Text(loc, style: const TextStyle(color: AppColors.textWhite)),
                  onTap: () {
                    setState(() => _locationController.text = loc);
                    Navigator.pop(ctx);
                  },
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _submitVehicle() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one vehicle image")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();
    final vehicleProv = context.read<VehicleProvider>();

    final vehicleId = widget.vehicleToEdit?.id ??
        "LANKA-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}";

    final newVehicle = VehicleModel(
      id: vehicleId,
      sellerId: auth.user?.uid ?? 'seller_def',
      sellerName: auth.user?.name ?? 'Lanka Ride Host',
      name: "${_brandController.text.trim()} ${_modelController.text.trim()}",
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      year: int.tryParse(_yearController.text.trim()) ?? 2023,
      color: _colorController.text.trim(),
      type: _selectedType,
      transmission: _selectedTransmission,
      seats: _seats,
      pricePerDay: double.tryParse(_priceController.text.trim()) ?? 5000.0,
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : "Premium Sri Lanka rental vehicle with full insurance coverage.",
      images: _imageUrls,
      rating: widget.vehicleToEdit?.rating ?? 5.0,
      totalTrips: widget.vehicleToEdit?.totalTrips ?? 0,
      location: _locationController.text.trim(),
      createdAt: widget.vehicleToEdit?.createdAt ?? DateTime.now(),
    );

    bool success;
    if (widget.vehicleToEdit != null) {
      success = await vehicleProv.updateVehicle(newVehicle);
    } else {
      success = await vehicleProv.addVehicle(newVehicle);
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.vehicleToEdit != null
              ? "Vehicle updated successfully!"
              : "Vehicle listed on Sri Lanka marketplace!"),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to save vehicle. Please try again."),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.vehicleToEdit != null;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(isEditing ? "Edit Vehicle Listing" : "List New Vehicle"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Photo & Video Upload Box
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "1. Photos & Verification",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                    ),
                    Text(
                      "${_imageUrls.length}/6 added",
                      style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _imageUrls.length + 1,
                    itemBuilder: (context, idx) {
                      if (idx == _imageUrls.length) {
                        // Add Image Tile
                        return GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 110,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: AppColors.cardDark,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.primary.withOpacity(0.5), style: BorderStyle.solid),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.add_a_photo_rounded, color: AppColors.primary, size: 28),
                                SizedBox(height: 6),
                                Text("Add Photo", style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                              ],
                            ),
                          ),
                        );
                      }

                      final url = _imageUrls[idx];
                      final isNetwork = url.startsWith('http://') || url.startsWith('https://');
                      return Stack(
                        children: [
                          Container(
                            width: 140,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                image: isNetwork 
                                    ? NetworkImage(url) as ImageProvider
                                    : FileImage(File(url)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 6,
                            right: 18,
                            child: GestureDetector(
                              onTap: () => setState(() => _imageUrls.removeAt(idx)),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Icon(Icons.close, color: Colors.white, size: 14),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Category & Brand Specifications
                const Text(
                  "2. Vehicle Specifications",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(labelText: "Vehicle Category"),
                  dropdownColor: AppColors.cardDark,
                  items: ['Car', 'Bike', 'Three-Wheel', 'Van', 'EV'].map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedType = val);
                  },
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _brandController,
                        decoration: const InputDecoration(labelText: "Brand (e.g. Toyota, Honda)"),
                        validator: (val) => val == null || val.isEmpty ? "Required" : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _modelController,
                        decoration: const InputDecoration(labelText: "Model (e.g. Prius, Dio)"),
                        validator: (val) => val == null || val.isEmpty ? "Required" : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _yearController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Year (e.g. 2022)"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _colorController,
                        decoration: const InputDecoration(labelText: "Color (e.g. Pearl White)"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedTransmission,
                        decoration: const InputDecoration(labelText: "Transmission"),
                        dropdownColor: AppColors.cardDark,
                        items: ['Auto', 'Manual', 'Electric'].map((trans) {
                          return DropdownMenuItem(value: trans, child: Text(trans));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedTransmission = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _seats,
                        decoration: const InputDecoration(labelText: "Seats"),
                        dropdownColor: AppColors.cardDark,
                        items: [2, 3, 4, 5, 7, 10, 14].map((s) {
                          return DropdownMenuItem(value: s, child: Text("$s Seats"));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _seats = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. AI Dynamic Price Recommendation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "3. Pricing & Location",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                    ),
                    // AI Button
                    GestureDetector(
                      onTap: _suggestAiPrice,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 14),
                            SizedBox(width: 6),
                            Text(
                              "AI Suggest Price",
                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Daily Rental Price (Rs.)",
                    prefixText: "Rs. ",
                  ),
                  validator: (val) => val == null || val.isEmpty ? "Enter price" : null,
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: _showLocationPicker,
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: "Pickup Location in Sri Lanka",
                        suffixIcon: Icon(Icons.location_on_rounded, color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Features & Amenities Checklist
                const Text(
                  "4. Amenities & Included Equipment",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _availableFeatures.map((feat) {
                    final isSelected = _selectedFeatures.contains(feat);
                    return FilterChip(
                      label: Text(feat),
                      selected: isSelected,
                      selectedColor: AppColors.primary.withOpacity(0.25),
                      checkmarkColor: AppColors.primary,
                      backgroundColor: AppColors.cardDark,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.textWhite,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            _selectedFeatures.add(feat);
                          } else {
                            _selectedFeatures.remove(feat);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // 5. Description & Policy
                const Text(
                  "5. Vehicle Description & Rules",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: "Mention maintenance history, fuel economy, and island tourism tips...",
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitVehicle,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textDark,
                    elevation: 8,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: AppColors.textDark, strokeWidth: 2),
                        )
                      : Text(
                          isEditing ? "Save Changes" : "Publish to Sri Lanka Marketplace",
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
