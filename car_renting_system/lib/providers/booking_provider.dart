import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/firestore_service.dart';

class BookingProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<BookingModel> _buyerBookings = [];
  List<BookingModel> _sellerBookings = [];
  bool _isLoading = false;
  String? _error;

  List<BookingModel> get buyerBookings => _buyerBookings;
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
        _buyerBookings = bookings;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
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

  Future<bool> confirmBooking(String bookingId) async {
    try {
      await _firestoreService.updateBookingStatus(bookingId, 'confirmed');
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelBooking(BookingModel booking) async {
    try {
      await _firestoreService.cancelBooking(booking);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeBooking(BookingModel booking) async {
    try {
      await _firestoreService.completeBooking(booking);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
