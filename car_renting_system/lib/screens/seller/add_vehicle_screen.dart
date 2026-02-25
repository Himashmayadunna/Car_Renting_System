import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../models/vehicle_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vehicle_provider.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _seatsController = TextEditingController(text: '5');
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _locationController = TextEditingController();
  final _insuranceDetailsController = TextEditingController();
  final _featureController = TextEditingController();

  String _selectedType = 'Standard';
  String _selectedTransmission = 'Automatic';
  bool _hasInsurance = false;
  final List<String> _features = [];
  bool _isSubmitting = false;

  final _types = ['Standard', 'Comfort', 'Business'];
  final _transmissions = ['Automatic', 'Manual'];

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _seatsController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _licensePlateController.dispose();
    _locationController.dispose();
    _insuranceDetailsController.dispose();
    _featureController.dispose();
    super.dispose();
  }

  void _addFeature() {
    final text = _featureController.text.trim();
    if (text.isNotEmpty && !_features.contains(text)) {
      setState(() {
        _features.add(text);
        _featureController.clear();
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final auth = context.read<AuthProvider>();
    final vehicleProv = context.read<VehicleProvider>();

    if (auth.user == null) return;

    final vehicle = VehicleModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sellerId: auth.user!.uid,
      sellerName: auth.user!.name,
      name: "${_brandController.text.trim()} ${_modelController.text.trim()}",
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      year: int.tryParse(_yearController.text.trim()) ?? DateTime.now().year,
      color: _colorController.text.trim(),
      type: _selectedType,
      transmission: _selectedTransmission,
      seats: int.tryParse(_seatsController.text.trim()) ?? 5,
      pricePerDay: double.tryParse(_priceController.text.trim()) ?? 0,
      description: _descriptionController.text.trim(),
      features: _features,
      images: [], // Image upload could be added later
      licensePlate: _licensePlateController.text.trim(),
      hasInsurance: _hasInsurance,
      insuranceDetails: _hasInsurance
          ? _insuranceDetailsController.text.trim()
          : null,
      location: _locationController.text.trim(),
      createdAt: DateTime.now(),
    );

    final success = await vehicleProv.addVehicle(vehicle);

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vehicle added successfully!"),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to add vehicle"),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Vehicle"),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic info section
              _sectionHeader("Vehicle Details"),
              const SizedBox(height: 12),
              _buildField(_brandController, "Brand", "e.g. Toyota",
                  icon: Icons.directions_car),
              _buildField(_modelController, "Model", "e.g. Camry",
                  icon: Icons.info_outline),
              Row(
                children: [
                  Expanded(
                    child: _buildField(_yearController, "Year", "e.g. 2023",
                        icon: Icons.calendar_today,
                        keyboardType: TextInputType.number),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(_colorController, "Color", "e.g. Black",
                        icon: Icons.palette_outlined),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                        _seatsController, "Seats", "e.g. 5",
                        icon: Icons.event_seat_outlined,
                        keyboardType: TextInputType.number),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                        _licensePlateController, "License Plate", "ABC-1234",
                        icon: Icons.credit_card),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Type & Transmission
              _sectionHeader("Category"),
              const SizedBox(height: 12),
              const Text("Vehicle Type",
                  style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
              const SizedBox(height: 8),
              _buildChipSelector(_types, _selectedType, (val) {
                setState(() => _selectedType = val);
              }),
              const SizedBox(height: 16),
              const Text("Transmission",
                  style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
              const SizedBox(height: 8),
              _buildChipSelector(_transmissions, _selectedTransmission, (val) {
                setState(() => _selectedTransmission = val);
              }),
              const SizedBox(height: 20),

              // Price
              _sectionHeader("Pricing"),
              const SizedBox(height: 12),
              _buildField(_priceController, "Price per Day (\$)", "e.g. 50",
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 20),

              // Features
              _sectionHeader("Features"),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _featureController,
                      decoration: const InputDecoration(
                        hintText: "e.g. GPS, Bluetooth, Sunroof",
                        prefixIcon: Icon(Icons.add_circle_outline,
                            color: AppColors.textGrey, size: 20),
                      ),
                      onFieldSubmitted: (_) => _addFeature(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addFeature,
                    icon: const Icon(Icons.add, color: AppColors.primary),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
              if (_features.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _features
                      .map((f) => Chip(
                            label: Text(f, style: const TextStyle(fontSize: 12)),
                            deleteIconColor: AppColors.error,
                            backgroundColor: AppColors.surfaceGrey,
                            onDeleted: () {
                              setState(() => _features.remove(f));
                            },
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 20),

              // Insurance
              _sectionHeader("Insurance"),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _hasInsurance,
                onChanged: (val) => setState(() => _hasInsurance = val),
                title: const Text("Vehicle has insurance"),
                activeTrackColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
              if (_hasInsurance)
                _buildField(_insuranceDetailsController, "Insurance Details",
                    "Policy info, coverage, etc.",
                    icon: Icons.shield_outlined, maxLines: 2),
              const SizedBox(height: 20),

              // Description & Location
              _sectionHeader("Additional Info"),
              const SizedBox(height: 12),
              _buildField(_descriptionController, "Description",
                  "Tell renters about your vehicle...",
                  icon: Icons.description_outlined, maxLines: 3),
              _buildField(_locationController, "Location",
                  "Where can the vehicle be picked up?",
                  icon: Icons.location_on_outlined),

              const SizedBox(height: 30),

              // Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Add Vehicle"),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    String hint, {
    IconData? icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon:
              icon != null ? Icon(icon, color: AppColors.textGrey, size: 20) : null,
        ),
        validator: (val) {
          if (label == 'Brand' ||
              label == 'Model' ||
              label.startsWith('Price')) {
            if (val == null || val.trim().isEmpty) {
              return '$label is required';
            }
          }
          return null;
        },
      ),
    );
  }

  Widget _buildChipSelector(
      List<String> options, String selected, ValueChanged<String> onTap) {
    return Row(
      children: options.map((opt) {
        final isSelected = opt == selected;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: ChoiceChip(
            label: Text(opt),
            selected: isSelected,
            onSelected: (_) => onTap(opt),
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(
              color: isSelected ? AppColors.textDark : AppColors.textWhite,
              fontWeight: FontWeight.w500,
            ),
            backgroundColor: AppColors.surfaceGrey,
            side: BorderSide.none,
          ),
        );
      }).toList(),
    );
  }
}
