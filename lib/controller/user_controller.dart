import '../model/userModel.dart';
import '../model/barang_model.dart';
import '../model/review_model.dart';
import '../services/database_helper.dart';

class UserController {
  final dbHelper = DatabaseHelper.instance;

  // Get user by ID
  Future<UserModel?> getUserById(int userId) async {
    try {
      final db = await dbHelper.database;

      final List<Map<String, dynamic>> users = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (users.isEmpty) {
        return null;
      }

      return UserModel.fromMap(users.first);
    } catch (e) {
      print('Error getUserById: $e');
      return null;
    }
  }

  // Get all products from a specific user
  Future<List<BarangJualanModel>> getUserProducts(int userId) async {
    try {
      final db = await dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'barang_jualan',
        where: 'id_penjual = ?',
        whereArgs: [userId],
        orderBy: 'tanggal_upload DESC',
      );

      return List.generate(maps.length, (i) {
        return BarangJualanModel.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error getUserProducts: $e');
      return [];
    }
  }

  // Get all reviews for a specific seller
  Future<List<ReviewModel>> getUserReviews(int sellerId) async {
    try {
      final db = await dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'reviews',
        where: 'seller_id = ?',
        whereArgs: [sellerId],
        orderBy: 'created_at DESC',
      );

      List<ReviewModel> reviews = [];

      for (var map in maps) {
        ReviewModel review = ReviewModel.fromMap(map);

        // Get buyer info
        if (review.buyerId != null) {
          final buyer = await getUserById(review.buyerId!);
          review.buyerName = buyer?.uName;
          review.buyerPhoto = buyer?.uFotoProfil;
        }

        reviews.add(review);
      }

      return reviews;
    } catch (e) {
      print('Error getUserReviews: $e');
      return [];
    }
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStatistics(int userId) async {
    try {
      final db = await dbHelper.database;

      // Count total products
      final productCount = await db.rawQuery(
        'SELECT COUNT(*) as count FROM barang_jualan WHERE id_penjual = ?',
        [userId],
      );

      // Count total reviews
      final reviewCount = await db.rawQuery(
        'SELECT COUNT(*) as count FROM reviews WHERE seller_id = ?',
        [userId],
      );

      // Get sold items count (from transactions - simplified for local demo)
      // In a real app, you'd track sold items properly
      final soldCount = 0; // Placeholder

      return {
        'products': productCount.first['count'] as int,
        'reviews': reviewCount.first['count'] as int,
        'sold': soldCount,
      };
    } catch (e) {
      print('Error getUserStatistics: $e');
      return {
        'products': 0,
        'reviews': 0,
        'sold': 0,
      };
    }
  }

  // Update user rating after review
  Future<bool> updateUserRating(int userId) async {
    try {
      final db = await dbHelper.database;

      // Calculate average rating
      final result = await db.rawQuery(
        'SELECT AVG(rating) as avg_rating, COUNT(*) as total FROM reviews WHERE seller_id = ?',
        [userId],
      );

      if (result.isNotEmpty) {
        final avgRating = result.first['avg_rating'] as double? ?? 0.0;
        final totalReviews = result.first['total'] as int? ?? 0;

        await db.update(
          'users',
          {
            'rating': avgRating,
            'total_reviews': totalReviews,
          },
          where: 'id = ?',
          whereArgs: [userId],
        );

        return true;
      }

      return false;
    } catch (e) {
      print('Error updateUserRating: $e');
      return false;
    }
  }

  // Add a review
  Future<bool> addReview(ReviewModel review) async {
    try {
      final db = await dbHelper.database;

      await db.insert('reviews', review.toMap());

      // Update seller's rating
      if (review.sellerId != null) {
        await updateUserRating(review.sellerId!);
      }

      return true;
    } catch (e) {
      print('Error addReview: $e');
      return false;
    }
  }

  // Check if user has already reviewed a seller for a transaction
  Future<bool> hasReviewed(int buyerId, int sellerId, String transaksiId) async {
    try {
      final db = await dbHelper.database;

      final result = await db.query(
        'reviews',
        where: 'buyer_id = ? AND seller_id = ? AND transaksi_id = ?',
        whereArgs: [buyerId, sellerId, transaksiId],
      );

      return result.isNotEmpty;
    } catch (e) {
      print('Error hasReviewed: $e');
      return false;
    }
  }

  // Get all users (for demo purposes)
  Future<List<UserModel>> getAllUsers() async {
    try {
      final db = await dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        orderBy: 'created_at DESC',
      );

      return List.generate(maps.length, (i) {
        return UserModel.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error getAllUsers: $e');
      return [];
    }
  }

  // Search users by name
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final db = await dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'name LIKE ?',
        whereArgs: ['%$query%'],
        orderBy: 'name ASC',
      );

      return List.generate(maps.length, (i) {
        return UserModel.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error searchUsers: $e');
      return [];
    }
  }
}