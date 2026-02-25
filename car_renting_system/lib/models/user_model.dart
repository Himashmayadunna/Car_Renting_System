class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role; // 'buyer' or 'seller'
  final String? profileImage;
  final double rating;
  final int totalReviews;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.profileImage,
    this.rating = 0.0,
    this.totalReviews = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'profileImage': profileImage,
      'rating': rating,
      'totalReviews': totalReviews,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'buyer',
      profileImage: map['profileImage'],
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalReviews: map['totalReviews'] ?? 0,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  UserModel copyWith({
    String? name,
    String? phone,
    String? profileImage,
    double? rating,
    int? totalReviews,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      role: role,
      profileImage: profileImage ?? this.profileImage,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      createdAt: createdAt,
    );
  }
}
