import 'package:flutter/material.dart';
import '../models/vehicle_model.dart';
import '../services/firestore_service.dart';

class VehicleProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<VehicleModel> _vehicles = [];
  List<VehicleModel> _sellerVehicles = [];
  bool _isLoading = false;
  String? _error;
  String _selectedType = 'All';
  String _selectedTransmission = 'All';
  double _maxPrice = 50000.0;
  String _selectedLocationFilter = 'All';

  static final List<VehicleModel> _sampleVehicles = [
    VehicleModel(
      id: 'sample_1',
      sellerId: 'seller_1',
      sellerName: 'Lanka Ride Rentals',
      name: 'Honda Dio 110',
      brand: 'HONDA',
      model: 'Dio 110',
      year: 2023,
      color: 'Matte Blue',
      type: 'Scooter',
      transmission: 'Auto',
      seats: 2,
      pricePerDay: 3500,
      description: 'Fuel efficient scooter perfect for navigating Colombo traffic.',
      images: const ['https://images.unsplash.com/photo-1558981806-ec527fa84c39?auto=format&fit=crop&w=600&q=75'],
      rating: 4.9,
      totalTrips: 58,
      location: 'Colombo 03',
      createdAt: DateTime(2024, 1, 1),
    ),
    VehicleModel(
      id: 'sample_2',
      sellerId: 'seller_2',
      sellerName: 'Island Rentals',
      name: 'Toyota Axio Hybrid',
      brand: 'TOYOTA',
      model: 'Axio Hybrid',
      year: 2021,
      color: 'White',
      type: 'Car',
      transmission: 'Automatic',
      seats: 5,
      pricePerDay: 8900,
      description: 'Comfortable family car.',
      images: const ['https://images.unsplash.com/photo-1542296332-2e4473faf563?auto=format&fit=crop&w=600&q=75'],
      rating: 4.8,
      totalTrips: 72,
      location: 'Nugegoda',
      createdAt: DateTime(2024, 1, 1),
    ),
    VehicleModel(
      id: 'sample_3',
      sellerId: 'seller_3',
      sellerName: 'Mountain Bikes SL',
      name: 'Yamaha FZ v3',
      brand: 'YAMAHA',
      model: 'FZ v3',
      year: 2022,
      color: 'Black',
      type: 'Bike',
      transmission: 'Manual',
      seats: 2,
      pricePerDay: 5000,
      description: 'Great bike for island trips.',
      images: const ['https://images.unsplash.com/photo-1558981420-c532902e58b4?auto=format&fit=crop&w=600&q=75'],
      rating: 4.7,
      totalTrips: 40,
      location: 'Kandy',
      createdAt: DateTime(2024, 1, 1),
    ),
    VehicleModel(
      id: 'sample_4',
      sellerId: 'seller_4',
      sellerName: 'Royal Lanka Cabs',
      name: 'Land Cruiser Prado',
      brand: 'TOYOTA',
      model: 'Prado',
      year: 2022,
      color: 'Pearl White',
      type: 'SUV',
      transmission: 'Automatic',
      seats: 7,
      pricePerDay: 24500,
      description: 'Luxury SUV for all-terrain comfort.',
      images: const ['https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=600&q=75'],
      rating: 4.9,
      totalTrips: 64,
      location: 'Colombo 07',
      createdAt: DateTime(2024, 1, 1),
    ),
    VehicleModel(
      id: 'sample_5',
      sellerId: 'seller_5',
      sellerName: 'Lanka Vans',
      name: 'Toyota Hiace KDH',
      brand: 'TOYOTA',
      model: 'Hiace',
      year: 2019,
      color: 'White',
      type: 'Van',
      transmission: 'Automatic',
      seats: 12,
      pricePerDay: 18000,
      description: 'Spacious van for family trips.',
      images: const ['https://images.unsplash.com/photo-1544620347-c4fd4a3d5f57?auto=format&fit=crop&w=600&q=75'],
      rating: 4.6,
      totalTrips: 80,
      location: 'Negombo',
      createdAt: DateTime(2024, 1, 1),
    ),
  ];

  List<VehicleModel> get rawVehicles => _vehicles.isNotEmpty ? _vehicles : _sampleVehicles;
  List<VehicleModel> get vehicles {
    final baseList = _vehicles.isNotEmpty ? _vehicles : _sampleVehicles;
    return baseList.where((v) {
      final matchesType = _selectedType == 'All' || v.type.toLowerCase() == _selectedType.toLowerCase();
      final matchesTrans = _selectedTransmission == 'All' || v.transmission.toLowerCase().contains(_selectedTransmission.toLowerCase());
      final matchesPrice = v.pricePerDay <= _maxPrice;
      final matchesLoc = _selectedLocationFilter == 'All' || v.location.toLowerCase().contains(_selectedLocationFilter.toLowerCase());
      return matchesType && matchesTrans && matchesPrice && matchesLoc;
    }).toList();
  }

  List<VehicleModel> get filteredVehicles => vehicles;

  List<VehicleModel> get sellerVehicles => _sellerVehicles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedType => _selectedType;
  String get selectedTransmission => _selectedTransmission;
  double get maxPrice => _maxPrice;
  String get selectedLocationFilter => _selectedLocationFilter;

  bool get hasActiveFilters =>
      _selectedType != 'All' ||
      _selectedTransmission != 'All' ||
      _maxPrice < 50000.0 ||
      _selectedLocationFilter != 'All';

  void setType(String type) {
    _selectedType = type;
    notifyListeners();
  }

  void setTransmission(String transmission) {
    _selectedTransmission = transmission;
    notifyListeners();
  }

  void setMaxPrice(double price) {
    _maxPrice = price;
    notifyListeners();
  }

  void setLocationFilter(String location) {
    _selectedLocationFilter = location;
    notifyListeners();
  }

  void resetFilters() {
    _selectedType = 'All';
    _selectedTransmission = 'All';
    _maxPrice = 50000.0;
    _selectedLocationFilter = 'All';
    notifyListeners();
  }

  void listenToAvailableVehicles() {
    _firestoreService.getAvailableVehicles().listen(
      (vehicles) {
        _vehicles = vehicles;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  void listenToSellerVehicles(String sellerId) {
    _firestoreService.getSellerVehicles(sellerId).listen(
      (vehicles) {
        _sellerVehicles = vehicles;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  Future<bool> addVehicle(VehicleModel vehicle) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.addVehicle(vehicle);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateVehicle(VehicleModel vehicle) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestoreService.updateVehicle(vehicle);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteVehicle(String vehicleId) async {
    try {
      await _firestoreService.deleteVehicle(vehicleId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleAvailability(VehicleModel vehicle) async {
    final updated = vehicle.copyWith(isAvailable: !vehicle.isAvailable);
    await _firestoreService.updateVehicle(updated);
  }
}
