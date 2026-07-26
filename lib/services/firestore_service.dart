import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehicle_model.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';

/// Cloud Firestore data service.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==================== VEHICLES ====================

  Future<void> addVehicle(VehicleModel vehicle) async {
    await _db.collection('vehicles').doc(vehicle.id).set(vehicle.toMap());
  }

  Future<void> updateVehicle(VehicleModel vehicle) async {
    await _db.collection('vehicles').doc(vehicle.id).update(vehicle.toMap());
  }

  Future<void> deleteVehicle(String vehicleId) async {
    await _db.collection('vehicles').doc(vehicleId).delete();
  }

  Stream<List<VehicleModel>> getAvailableVehicles() {
    return _db
        .collection('vehicles')
        .where('isAvailable', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VehicleModel.fromMap(doc.data()))
            .toList());
  }

  Stream<List<VehicleModel>> getSellerVehicles(String sellerId) {
    return _db
        .collection('vehicles')
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VehicleModel.fromMap(doc.data()))
            .toList());
  }

  Future<VehicleModel?> getVehicle(String vehicleId) async {
    final doc = await _db.collection('vehicles').doc(vehicleId).get();
    if (!doc.exists) return null;
    return VehicleModel.fromMap(doc.data()!);
  }

  Stream<List<VehicleModel>> getVehiclesByType(String type) {
    return _db
        .collection('vehicles')
        .where('isAvailable', isEqualTo: true)
        .where('type', isEqualTo: type)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VehicleModel.fromMap(doc.data()))
            .toList());
  }

  // ==================== BOOKINGS ====================

  Future<void> createBooking(BookingModel booking) async {
    await _db.collection('bookings').doc(booking.id).set(booking.toMap());
    // Mark vehicle as unavailable
    await _db.collection('vehicles').doc(booking.vehicleId).update({
      'isAvailable': false,
    });
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': status,
    });
  }

  Future<void> completeBooking(BookingModel booking) async {
    await updateBookingStatus(booking.id, 'completed');
    // Mark vehicle as available again
    await _db.collection('vehicles').doc(booking.vehicleId).update({
      'isAvailable': true,
    });
  }

  Future<void> cancelBooking(BookingModel booking) async {
    await updateBookingStatus(booking.id, 'cancelled');
    // Mark vehicle as available again
    await _db.collection('vehicles').doc(booking.vehicleId).update({
      'isAvailable': true,
    });
  }

  Stream<List<BookingModel>> getBuyerBookings(String buyerId) {
    return _db
        .collection('bookings')
        .where('buyerId', isEqualTo: buyerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data()))
            .toList());
  }

  Stream<List<BookingModel>> getSellerBookings(String sellerId) {
    return _db
        .collection('bookings')
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data()))
            .toList());
  }

  // ==================== USER ====================

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }
}
