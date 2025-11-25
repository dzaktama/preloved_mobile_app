class UserModel {
  int? id;
  String? uName;
  String? uEmail;
  String? uPassword;
  String? uPhone;
  String? uAddress;
  String? uFotoProfil;
  String? uRole;
  String? createdAt;
  
  // NEW FIELDS
  double? rating;
  int? totalReviews;
  double? responseRate;
  String? bio;
  String? joinDate;

  UserModel({
    this.id,
    this.uName,
    this.uEmail,
    this.uPassword,
    this.uPhone,
    this.uAddress,
    this.uFotoProfil,
    this.uRole = 'user',
    this.createdAt,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.responseRate = 100.0,
    this.bio,
    this.joinDate,
  });

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': uName,
      'email': uEmail,
      'password': uPassword,
      'phone': uPhone,
      'address': uAddress,
      'foto_profil': uFotoProfil,
      'role': uRole,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
      'rating': rating,
      'total_reviews': totalReviews,
      'response_rate': responseRate,
      'bio': bio,
      'join_date': joinDate ?? DateTime.now().toIso8601String(),
    };
  }

  // Create from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      uName: map['name'] as String?,
      uEmail: map['email'] as String?,
      uPassword: map['password'] as String?,
      uPhone: map['phone'] as String?,
      uAddress: map['address'] as String?,
      uFotoProfil: map['foto_profil'] as String?,
      uRole: map['role'] as String? ?? 'user',
      createdAt: map['created_at'] as String?,
      rating: map['rating'] as double? ?? 0.0,
      totalReviews: map['total_reviews'] as int? ?? 0,
      responseRate: map['response_rate'] as double? ?? 100.0,
      bio: map['bio'] as String?,
      joinDate: map['join_date'] as String?,
    );
  }

  UserModel copy({
    int? id,
    String? uName,
    String? uEmail,
    String? uPassword,
    String? uPhone,
    String? uAddress,
    String? uFotoProfil,
    String? uRole,
    String? createdAt,
    double? rating,
    int? totalReviews,
    double? responseRate,
    String? bio,
    String? joinDate,
  }) {
    return UserModel(
      id: id ?? this.id,
      uName: uName ?? this.uName,
      uEmail: uEmail ?? this.uEmail,
      uPassword: uPassword ?? this.uPassword,
      uPhone: uPhone ?? this.uPhone,
      uAddress: uAddress ?? this.uAddress,
      uFotoProfil: uFotoProfil ?? this.uFotoProfil,
      uRole: uRole ?? this.uRole,
      createdAt: createdAt ?? this.createdAt,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      responseRate: responseRate ?? this.responseRate,
      bio: bio ?? this.bio,
      joinDate: joinDate ?? this.joinDate,
    );
  }

  // Helper getter for display
  String get ratingDisplay => rating?.toStringAsFixed(1) ?? '0.0';
  String get totalReviewsDisplay => totalReviews?.toString() ?? '0';
  String get responseRateDisplay => '${responseRate?.toStringAsFixed(0) ?? '100'}%';
}