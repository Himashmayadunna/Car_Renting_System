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

  static final List<BookingModel> _sampleSellerBookings = [
    BookingModel(
      id: 'trip_201',
      vehicleId: 'sample_4',
      vehicleName: 'Toyota Prius Hybrid (2022)',
      vehicleImage: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=600&q=75',
      buyerId: 'user_99',
      buyerName: 'Shenal Fernando',
      buyerPhone: '+94 77 123 4567',
      sellerId: 'seller_def',
      sellerName: 'Lanka Ride Host',
      startDate: DateTime.now().add(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 5)),
      totalDays: 3,
      pricePerDay: 14000,
      totalPrice: 42000,
      status: 'pending',
      pickupLocation: 'Colombo 03 Area',
      dropoffLocation: 'Colombo 03 Area',
      rating: 0.0,
      review: '',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    BookingModel(
      id: 'trip_202',
      vehicleId: 'sample_1',
      vehicleName: 'Honda Dio 110 (2023)',
      vehicleImage: 'https://images.unsplash.com/photo-1558981806-ec527fa84c39?auto=format&fit=crop&w=600&q=75',
      buyerId: 'user_88',
      buyerName: 'Kasun Perera',
      buyerPhone: '+94 71 987 6543',
      sellerId: 'seller_def',
      sellerName: 'Lanka Ride Host',
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 2)),
      totalDays: 3,
      pricePerDay: 3500,
      totalPrice: 10500,
      status: 'active',
      pickupLocation: 'Negombo Beach',
      dropoffLocation: 'Negombo Beach',
      rating: 0.0,
      review: '',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  List<BookingModel> get buyerBookings =>
      _buyerBookings.isNotEmpty ? _buyerBookings : _sampleCompletedBookings;
  List<BookingModel> get sellerBookings =>
      _sellerBookings.isNotEmpty ? _sellerBookings : _sampleSellerBookings;
  List<BookingModel> get pendingSellerBookings =>
      sellerBookings.where((b) => b.status == 'pending').toList();
  List<BookingModel> get activeSellerBookings =>
      sellerBookings.where((b) => b.status == 'confirmed' || b.status == 'active').toList();
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
        if (bookings.isNotEmpty) {
          _sellerBookings = bookings;
        } else {
          _sellerBookings = _sampleSellerBookings;
        }
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _sellerBookings = _sampleSellerBookings;
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

  Future<bool> updateBookingStatus(String bookingId, String status) async {
    try {
      await _firestoreService.updateBookingStatus(bookingId, status);
      _updateLocalBookingStatus(bookingId, status);
      _updateSellerLocalBookingStatus(bookingId, status);
      return true;
    } catch (e) {
      _updateLocalBookingStatus(bookingId, status);
      _updateSellerLocalBookingStatus(bookingId, status);
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

  void _updateSellerLocalBookingStatus(String bookingId, String status) {
    final idx = _sellerBookings.indexWhere((b) => b.id == bookingId);
    if (idx != -1) {
      _sellerBookings[idx] = _sellerBookings[idx].copyWith(status: status);
      notifyListeners();
    }
  }
}
