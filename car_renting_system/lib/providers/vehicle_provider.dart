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

  List<VehicleModel> get vehicles => _selectedType == 'All'
      ? _vehicles
      : _vehicles.where((v) => v.type == _selectedType).toList();
  List<VehicleModel> get sellerVehicles => _sellerVehicles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedType => _selectedType;

  void setType(String type) {
    _selectedType = type;
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
