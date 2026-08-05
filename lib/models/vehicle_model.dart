class VehicleModel {
  final String id;
  final String sellerId;
  final String sellerName;
  final String name;
  final String brand;
  final String model;
  final int year;
  final String color;
  final String type; // 'Standard', 'Comfort', 'Business'
  final String transmission; // 'Auto', 'Manual'
  final int seats;
  final double pricePerDay;
  final String description;
  final List<String> features; // AC, GPS, Bluetooth, etc.
  final List<String> images;
  final String? licensePlate;
  final bool hasInsurance;
  final String? insuranceDetails;
  final bool isAvailable;
  final double rating;
  final int totalTrips;
  final String location;
  final DateTime createdAt;

  VehicleModel({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.name,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    this.type = 'Standard',
    this.transmission = 'Auto',
    this.seats = 4,
    required this.pricePerDay,
    required this.description,
    this.features = const [],
    this.images = const [],
    this.licensePlate,
    this.hasInsurance = false,
    this.insuranceDetails,
    this.isAvailable = true,
    this.rating = 0.0,
    this.totalTrips = 0,
    this.location = '',
    required this.createdAt,
  });

  String get displayName => '$color $brand $model';
  String get priceDisplay => 'Rs. ${pricePerDay.toStringAsFixed(0)}';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'name': name,
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      'type': type,
      'transmission': transmission,
      'seats': seats,
      'pricePerDay': pricePerDay,
      'description': description,
      'features': features,
      'images': images,
      'licensePlate': licensePlate,
      'hasInsurance': hasInsurance,
      'insuranceDetails': insuranceDetails,
      'isAvailable': isAvailable,
      'rating': rating,
      'totalTrips': totalTrips,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory VehicleModel.fromMap(Map<String, dynamic> map) {
    return VehicleModel(
      id: map['id'] ?? '',
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      name: map['name'] ?? '',
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      year: map['year'] ?? 2024,
      color: map['color'] ?? '',
      type: map['type'] ?? 'Standard',
      transmission: map['transmission'] ?? 'Auto',
      seats: map['seats'] ?? 4,
      pricePerDay: (map['pricePerDay'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      features: List<String>.from(map['features'] ?? []),
      images: List<String>.from(map['images'] ?? []),
      licensePlate: map['licensePlate'],
      hasInsurance: map['hasInsurance'] ?? false,
      insuranceDetails: map['insuranceDetails'],
      isAvailable: map['isAvailable'] ?? true,
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalTrips: map['totalTrips'] ?? 0,
      location: map['location'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  VehicleModel copyWith({
    String? name,
    double? pricePerDay,
    String? description,
    List<String>? features,
    List<String>? images,
    bool? isAvailable,
    bool? hasInsurance,
    String? insuranceDetails,
    String? location,
  }) {
    return VehicleModel(
      id: id,
      sellerId: sellerId,
      sellerName: sellerName,
      name: name ?? this.name,
      brand: brand,
      model: model,
      year: year,
      color: color,
      type: type,
      transmission: transmission,
      seats: seats,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      description: description ?? this.description,
      features: features ?? this.features,
      images: images ?? this.images,
      licensePlate: licensePlate,
      hasInsurance: hasInsurance ?? this.hasInsurance,
      insuranceDetails: insuranceDetails ?? this.insuranceDetails,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating,
      totalTrips: totalTrips,
      location: location ?? this.location,
      createdAt: createdAt,
    );
  }
}
