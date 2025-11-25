class ReviewModel {
  int? id;
  int? sellerId;
  int? buyerId;
  String? transaksiId;
  double? rating;
  String? reviewText;
  String? createdAt;

  // Helper fields (not in database)
  String? buyerName;
  String? buyerPhoto;

  ReviewModel({
    this.id,
    this.sellerId,
    this.buyerId,
    this.transaksiId,
    this.rating,
    this.reviewText,
    this.createdAt,
    this.buyerName,
    this.buyerPhoto,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'seller_id': sellerId,
      'buyer_id': buyerId,
      'transaksi_id': transaksiId,
      'rating': rating,
      'review_text': reviewText,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] as int?,
      sellerId: map['seller_id'] as int?,
      buyerId: map['buyer_id'] as int?,
      transaksiId: map['transaksi_id'] as String?,
      rating: map['rating'] as double?,
      reviewText: map['review_text'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }

  DateTime? get createdAtDateTime {
    if (createdAt == null) return null;
    try {
      return DateTime.parse(createdAt!);
    } catch (e) {
      return null;
    }
  }

  String get ratingDisplay => rating?.toStringAsFixed(1) ?? '0.0';
}