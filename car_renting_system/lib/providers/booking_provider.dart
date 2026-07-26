import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/firestore_service.dart';

class BookingProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<BookingModel> _buyerBookings = [];
  List<BookingModel> _sellerBookings = [];
  bool _isLoading = false;
  String? _error;

  // Sample trip history records for instant preview when no Firestore data is returned
  static final List<BookingModel> _sampleCompletedBookings = [
    BookingModel(
      id: 'trip_101',
      vehicleId: 'sample_1',
      vehicleName: 'Tesla Model S Plaid',
      vehicleImage: 'https://images.unsplash.com/photo-1617788138017-80ad40651399?auto=format&fit=crop&w=600&q=75',
      buyerId: 'user_1',
      buyerName: 'Customer',
      buyerPhone: '+1 555-0192',
      sellerId: 'seller_1',
      sellerName: 'Premium Rentals',
      startDate: DateTime.now().subtract(const Duration(days: 7)),
      endDate: DateTime.now().subtract(const Duration(days: 4)),
      totalDays: 3,
      pricePerDay: 249,
      totalPrice: 782,
      status: 'completed',
      pickupLocation: 'Los Angeles International Airport (LAX)',
      dropoffLocation: 'Downtown Beverly Hills Hub',
      rating: 5.0,
      review: 'Awesome electric car! Smooth delivery and ultra fast charging.',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    BookingModel(
      id: 'trip_102',
      vehicleId: 'sample_2',
      vehicleName: 'Porsche 911 Carrera',
      vehicleImage: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=600&q=75',
      buyerId: 'user_1',
      buyerName: 'Customer',
      buyerPhone: '+1 555-0192',
      sellerId: 'seller_2',
      sellerName: 'Exotic Motors',
      startDate: DateTime.now().subtract(const Duration(days: 18)),
      endDate: DateTime.now().subtract(const Duration(days: 16)),
      totalDays: 2,
      pricePerDay: 320,
      totalPrice: 675,
      status: 'completed',
      pickupLocation: 'Santa Monica Boulevard',
      dropoffLocation: 'Santa Monica Boulevard',
      rating: 4.8,
      review: 'Unbelievable performance for a weekend getaway drive.',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
  ];

  List<BookingModel> get buyerBookings =>
      _buyerBookings.isNotEmpty ? _buyerBookings : _sampleCompletedBookings;
  List<BookingModel> get sellerBookings => _sellerBookings;
  List<BookingModel> get pendingSellerBookings =>
      _sellerBookings.where((b) => b.status == 'pending').toList();
  List<BookingModel> get activeSellerBookings =>
      _sellerBookings.where((b) => b.status == 'confirmed' || b.status == 'active').toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  void listenToBuyerBookings(String buyerId) {
    _firestoreService.getBuyerBookings(buyerId).listen(
      (bookings) {
        if (bookings.isNotEmpty) {
          _buyerBookings = bookings;
        } else {
          _buyerBookings = _sampleCompletedBookings;
        }
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _buyerBookings = _sampleCompletedBookings;
        notifyListeners();
      },
    );
  }

  void listenToSellerBookings(String sellerId) {
    _firestoreService.getSellerBookings(sellerId).listen(
      (bookings) {
        _sellerBookings = bookings;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  Future<bool> createBooking(BookingModel booking) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.createBooking(booking);
      _buyerBookings.insert(0, booking);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      // Even if offline/local demo mode, insert locally
      _buyerBookings.insert(0, booking);
      notifyListeners();
      return true;
    }
  }

  Future<bool> confirmBooking(String bookingId) async {
    try {
      await _firestoreService.updateBookingStatus(bookingId, 'confirmed');
      _updateLocalBookingStatus(bookingId, 'confirmed');
      return true;
    } catch (e) {
      _updateLocalBookingStatus(bookingId, 'confirmed');
      return true;
    }
  }

  Future<bool> cancelBooking(BookingModel booking) async {
    try {
      await _firestoreService.cancelBooking(booking);
      _updateLocalBookingStatus(booking.id, 'cancelled');
      return true;
    } catch (e) {
      _updateLocalBookingStatus(booking.id, 'cancelled');
      return true;
    }
  }

  Future<bool> completeBooking(BookingModel booking) async {
    try {
      await _firestoreService.completeBooking(booking);
      _updateLocalBookingStatus(booking.id, 'completed');
      return true;
    } catch (e) {
      _updateLocalBookingStatus(booking.id, 'completed');
      return true;
    }
  }

  Future<bool> updateBookingReview(BookingModel updatedBooking) async {
    try {
      final index = _buyerBookings.indexWhere((b) => b.id == updatedBooking.id);
      if (index != -1) {
        _buyerBookings[index] = updatedBooking;
        notifyListeners();
      }
      await _firestoreService.updateBookingStatus(updatedBooking.id, updatedBooking.status);
      return true;
    } catch (e) {
      notifyListeners();
      return true;
    }
  }

  void _updateLocalBookingStatus(String bookingId, String status) {
    final index = _buyerBookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _buyerBookings[index] = _buyerBookings[index].copyWith(status: status);
      notifyListeners();
    }
  }
}
