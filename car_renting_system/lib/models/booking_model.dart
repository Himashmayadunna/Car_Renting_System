class BookingModel {
  final String id;
  final String vehicleId;
  final String vehicleName;
  final String vehicleImage;
  final String buyerId;
  final String buyerName;
  final String buyerPhone;
  final String sellerId;
  final String sellerName;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final double pricePerDay;
  final double totalPrice;
  final String status; // 'pending', 'confirmed', 'active', 'completed', 'cancelled'
  final String? pickupLocation;
  final String? dropoffLocation;
  final String? notes;
  final double? rating;
  final String? review;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.vehicleId,
    required this.vehicleName,
    this.vehicleImage = '',
    required this.buyerId,
    required this.buyerName,
    this.buyerPhone = '',
    required this.sellerId,
    required this.sellerName,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.pricePerDay,
    required this.totalPrice,
    this.status = 'pending',
    this.pickupLocation,
    this.dropoffLocation,
    this.notes,
    this.rating,
    this.review,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'vehicleName': vehicleName,
      'vehicleImage': vehicleImage,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'buyerPhone': buyerPhone,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalDays': totalDays,
      'pricePerDay': pricePerDay,
      'totalPrice': totalPrice,
      'status': status,
      'pickupLocation': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'notes': notes,
      'rating': rating,
      'review': review,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] ?? '',
      vehicleId: map['vehicleId'] ?? '',
      vehicleName: map['vehicleName'] ?? '',
      vehicleImage: map['vehicleImage'] ?? '',
      buyerId: map['buyerId'] ?? '',
      buyerName: map['buyerName'] ?? '',
      buyerPhone: map['buyerPhone'] ?? '',
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      startDate: DateTime.parse(map['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(map['endDate'] ?? DateTime.now().toIso8601String()),
      totalDays: map['totalDays'] ?? 0,
      pricePerDay: (map['pricePerDay'] ?? 0.0).toDouble(),
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      pickupLocation: map['pickupLocation'],
      dropoffLocation: map['dropoffLocation'],
      notes: map['notes'],
      rating: map['rating'] != null ? (map['rating'] as num).toDouble() : null,
      review: map['review'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  BookingModel copyWith({
    String? status,
    double? rating,
    String? review,
    String? dropoffLocation,
  }) {
    return BookingModel(
      id: id,
      vehicleId: vehicleId,
      vehicleName: vehicleName,
      vehicleImage: vehicleImage,
      buyerId: buyerId,
      buyerName: buyerName,
      buyerPhone: buyerPhone,
      sellerId: sellerId,
      sellerName: sellerName,
      startDate: startDate,
      endDate: endDate,
      totalDays: totalDays,
      pricePerDay: pricePerDay,
      totalPrice: totalPrice,
      status: status ?? this.status,
      pickupLocation: pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      notes: notes,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      createdAt: createdAt,
    );
  }

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'active':
        return 'Active Ride';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
