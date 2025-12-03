// lib/services/layanan_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/product_model.dart';

class ApiService {
  static const String baseUrl = 'https://preloved-data-api.vercel.app';
  static const String authEndpoint = '/api/auth';
  static const String productsEndpoint = '/api/products';

  // Helper untuk decode response
  dynamic _tryDecode(String body) {
    try {
      return json.decode(body);
    } catch (_) {
      return body;
    }
  }

  // ==================== AUTH ENDPOINTS ====================
  
  /// Register user: POST /api/auth/register
  /// Body: { name, email, password, phone }
  Future<Map<String, dynamic>> registerUser(Map<String, dynamic> body) async {
    try {
      print('═══════════════════════════════════════');
      print('📤 REGISTER REQUEST');
      print('URL: $baseUrl$authEndpoint/register');
      print('Body: ${json.encode(body)}');
      
      final response = await http.post(
        Uri.parse('$baseUrl$authEndpoint/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));

      print('📥 REGISTER RESPONSE');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('═══════════════════════════════════════');

      final decoded = _tryDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': decoded is Map ? (decoded['message'] ?? 'User registered successfully') : 'User registered successfully',
          'statusCode': response.statusCode,
          'data': decoded is Map ? (decoded['user'] ?? decoded['data'] ?? decoded) : decoded,
          'raw': response.body,
        };
      }

      // Handle validation errors
      String errorMessage = 'Registration failed';
      if (decoded is Map) {
        if (decoded.containsKey('errors') && decoded['errors'] is List) {
          errorMessage = (decoded['errors'] as List).join(', ');
        } else if (decoded.containsKey('message')) {
          errorMessage = decoded['message'];
        } else if (decoded.containsKey('error')) {
          errorMessage = decoded['error'];
        }
      }

      return {
        'success': false,
        'message': errorMessage,
        'statusCode': response.statusCode,
        'data': null,
        'raw': response.body,
      };
    } catch (e) {
      print('❌ REGISTER ERROR: $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
        'data': null
      };
    }
  }

  /// Login user: POST /api/auth/login
  /// Body: { email, password }
  /// Returns: { success, token, user }
  Future<Map<String, dynamic>> loginUser(Map<String, dynamic> body) async {
    try {
      print('═══════════════════════════════════════');
      print('📤 LOGIN REQUEST');
      print('URL: $baseUrl$authEndpoint/login');
      print('Body: ${json.encode(body)}');
      
      final response = await http.post(
        Uri.parse('$baseUrl$authEndpoint/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));

      print('📥 LOGIN RESPONSE');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('═══════════════════════════════════════');

      final decoded = _tryDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': decoded is Map ? (decoded['message'] ?? 'Login successful') : 'Login successful',
          'statusCode': response.statusCode,
          'data': decoded, // Contains token and user data
          'raw': response.body,
        };
      }

      return {
        'success': false,
        'message': decoded is Map ? (decoded['message'] ?? decoded['error'] ?? 'Login failed') : 'Login failed',
        'statusCode': response.statusCode,
        'data': null,
        'raw': response.body,
      };
    } catch (e) {
      print('❌ LOGIN ERROR: $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
        'data': null
      };
    }
  }

  /// Get profile: GET /api/auth/me (Private)
  /// Requires: Authorization header with Bearer token
  Future<Map<String, dynamic>> getProfile(String token) async {
    try {
      print('API: Get profile with token: ${token.substring(0, 20)}...');
      
      final response = await http.get(
        Uri.parse('$baseUrl$authEndpoint/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      final decoded = _tryDecode(response.body);
      print('API: Get profile response -> status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Profile loaded',
          'data': decoded['user'] ?? decoded['data'] ?? decoded,
        };
      }

      return {
        'success': false,
        'message': decoded['message'] ?? 'Failed to load profile',
        'data': null
      };
    } catch (e) {
      print('API: Get profile error -> $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
        'data': null
      };
    }
  }

  /// Update profile: PUT /api/auth/updateprofile (Private)
  /// Body: { name?, phone?, address?, foto_profil? }
  Future<Map<String, dynamic>> updateProfile(String token, Map<String, dynamic> body) async {
    try {
      print('API: Update profile -> ${json.encode(body)}');
      
      final response = await http.put(
        Uri.parse('$baseUrl$authEndpoint/updateprofile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));

      final decoded = _tryDecode(response.body);
      print('API: Update profile response -> status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': decoded['message'] ?? 'Profile updated',
          'data': decoded['user'] ?? decoded['data'] ?? decoded,
        };
      }

      return {
        'success': false,
        'message': decoded['message'] ?? 'Failed to update profile',
        'data': null
      };
    } catch (e) {
      print('API: Update profile error -> $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
        'data': null
      };
    }
  }

  /// Update password: PUT /api/auth/updatepassword (Private)
  /// Body: { currentPassword, newPassword }
  Future<Map<String, dynamic>> updatePassword(String token, Map<String, dynamic> body) async {
    try {
      print('API: Update password');
      
      final response = await http.put(
        Uri.parse('$baseUrl$authEndpoint/updatepassword'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));

      final decoded = _tryDecode(response.body);
      print('API: Update password response -> status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': decoded['message'] ?? 'Password updated',
          'data': decoded,
        };
      }

      return {
        'success': false,
        'message': decoded['message'] ?? 'Failed to update password',
        'data': null
      };
    } catch (e) {
      print('API: Update password error -> $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
        'data': null
      };
    }
  }

  // ==================== PRODUCTS ENDPOINTS ====================

  /// Get all products: GET /api/products
  Future<Map<String, dynamic>> getAllProducts() async {
    try {
      print('API: Get all products');
      
      final response = await http.get(
        Uri.parse('$baseUrl$productsEndpoint'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      print('API: Get all products response -> status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = _tryDecode(response.body);
        List<ProductModel> products = [];

        if (decoded is List) {
          products = decoded.map<ProductModel>((e) => ProductModel.fromJson(e)).toList();
        } else if (decoded is Map<String, dynamic>) {
          final data = decoded['products'] ?? decoded['data'] ?? decoded['data_barang'];
          if (data is List) {
            products = data.map<ProductModel>((e) => ProductModel.fromJson(e)).toList();
          }
        }

        return {
          'success': true,
          'message': 'Products loaded successfully',
          'data': products,
        };
      }

      return {
        'success': false,
        'message': 'Failed to load products',
        'data': <ProductModel>[],
      };
    } catch (e) {
      print('API: Get all products error -> $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
        'data': <ProductModel>[],
      };
    }
  }

  /// Get product by ID: GET /api/products/:id
  Future<Map<String, dynamic>> getProductById(String id) async {
    try {
      print('API: Get product by ID -> $id');
      
      final response = await http.get(
        Uri.parse('$baseUrl$productsEndpoint/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final decoded = _tryDecode(response.body);
        final productData = decoded['product'] ?? decoded['data'] ?? decoded;
        
        return {
          'success': true,
          'message': 'Product loaded',
          'data': ProductModel.fromJson(productData),
        };
      }

      return {
        'success': false,
        'message': 'Product not found',
        'data': null
      };
    } catch (e) {
      print('API: Get product error -> $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
        'data': null
      };
    }
  }

  /// Get my products: GET /api/products/my/products (Private)
  Future<Map<String, dynamic>> getMyProducts(String token) async {
    try {
      print('API: Get my products');
      
      final response = await http.get(
        Uri.parse('$baseUrl$productsEndpoint/my/products'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final decoded = _tryDecode(response.body);
        List<ProductModel> products = [];

        final data = decoded['products'] ?? decoded['data'];
        if (data is List) {
          products = data.map<ProductModel>((e) => ProductModel.fromJson(e)).toList();
        }

        return {
          'success': true,
          'message': 'My products loaded',
          'data': products,
        };
      }

      return {
        'success': false,
        'message': 'Failed to load products',
        'data': <ProductModel>[],
      };
    } catch (e) {
      print('API: Get my products error -> $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
        'data': <ProductModel>[],
      };
    }
  }

  /// Get user products: GET /api/products/user/:userId
  Future<Map<String, dynamic>> getUserProducts(String userId) async {
    try {
      print('API: Get user products -> $userId');
      
      final response = await http.get(
        Uri.parse('$baseUrl$productsEndpoint/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final decoded = _tryDecode(response.body);
        List<ProductModel> products = [];

        final data = decoded['products'] ?? decoded['data'];
        if (data is List) {
          products = data.map<ProductModel>((e) => ProductModel.fromJson(e)).toList();
        }

        return {
          'success': true,
          'message': 'User products loaded',
          'data': products,
        };
      }

      return {
        'success': false,
        'message': 'Failed to load products',
        'data': <ProductModel>[],
      };
    } catch (e) {
      print('API: Get user products error -> $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
        'data': <ProductModel>[],
      };
    }
  }

  /// Create product: POST /api/products (Private)
  Future<Map<String, dynamic>> createProduct(String token, Map<String, dynamic> body) async {
    try {
      print('API: Create product -> ${json.encode(body)}');
      
      final response = await http.post(
        Uri.parse('$baseUrl$productsEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));

      final decoded = _tryDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': decoded['message'] ?? 'Product created',
          'data': decoded['product'] ?? decoded['data'] ?? decoded,
        };
      }

      return {
        'success': false,
        'message': decoded['message'] ?? 'Failed to create product',
        'data': null
      };
    } catch (e) {
      print('API: Create product error -> $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
        'data': null
      };
    }
  }

  /// Update product: PUT /api/products/:id (Private)
  Future<Map<String, dynamic>> updateProduct(String token, String id, Map<String, dynamic> body) async {
    try {
      print('API: Update product $id -> ${json.encode(body)}');
      
      final response = await http.put(
        Uri.parse('$baseUrl$productsEndpoint/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));

      final decoded = _tryDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': decoded['message'] ?? 'Product updated',
          'data': decoded['product'] ?? decoded['data'] ?? decoded,
        };
      }

      return {
        'success': false,
        'message': decoded['message'] ?? 'Failed to update product',
        'data': null
      };
    } catch (e) {
      print('API: Update product error -> $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
        'data': null
      };
    }
  }

  /// Delete product: DELETE /api/products/:id (Private)
  Future<Map<String, dynamic>> deleteProduct(String token, String id) async {
    try {
      print('API: Delete product -> $id');
      
      final response = await http.delete(
        Uri.parse('$baseUrl$productsEndpoint/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 204) {
        final decoded = response.statusCode == 200 ? _tryDecode(response.body) : {};
        return {
          'success': true,
          'message': decoded['message'] ?? 'Product deleted',
          'data': null
        };
      }

      return {
        'success': false,
        'message': 'Failed to delete product',
        'data': null
      };
    } catch (e) {
      print('API: Delete product error -> $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
        'data': null
      };
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Search products locally
  Future<Map<String, dynamic>> searchProducts(String query) async {
    try {
      final result = await getAllProducts();
      
      if (result['success']) {
        List<ProductModel> allProducts = result['data'];
        
        List<ProductModel> filteredProducts = allProducts.where((product) {
          final namaBarang = product.namaBarang.toLowerCase();
          final brand = product.brand.toLowerCase();
          final kategori = product.kategori.toLowerCase();
          final searchQuery = query.toLowerCase();
          
          return namaBarang.contains(searchQuery) ||
                 brand.contains(searchQuery) ||
                 kategori.contains(searchQuery);
        }).toList();

        return {
          'success': true,
          'message': 'Search completed',
          'data': filteredProducts,
        };
      }
      
      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Search failed: $e',
        'data': <ProductModel>[],
      };
    }
  }

  /// Filter products by category
  Future<Map<String, dynamic>> filterByCategory(String category) async {
    try {
      final result = await getAllProducts();
      
      if (result['success']) {
        List<ProductModel> allProducts = result['data'];
        
        List<ProductModel> filteredProducts = allProducts.where((product) {
          return product.kategori.toLowerCase() == category.toLowerCase();
        }).toList();

        return {
          'success': true,
          'message': 'Filter completed',
          'data': filteredProducts,
        };
      }
      
      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Filter failed: $e',
        'data': <ProductModel>[],
      };
    }
  }

  /// Sort products
  List<ProductModel> sortProducts(List<ProductModel> products, String sortBy) {
    List<ProductModel> sortedProducts = List.from(products);

    switch (sortBy) {
      case 'price_low_to_high':
        sortedProducts.sort((a, b) => a.hargaInt.compareTo(b.hargaInt));
        break;
      case 'price_high_to_low':
        sortedProducts.sort((a, b) => b.hargaInt.compareTo(a.hargaInt));
        break;
      case 'name_a_to_z':
        sortedProducts.sort((a, b) => a.namaBarang.compareTo(b.namaBarang));
        break;
      case 'name_z_to_a':
        sortedProducts.sort((a, b) => b.namaBarang.compareTo(a.namaBarang));
        break;
      case 'brand':
        sortedProducts.sort((a, b) => a.brand.compareTo(b.brand));
        break;
    }

    return sortedProducts;
  }

  /// Get unique categories
  Future<List<String>> getCategories() async {
    try {
      final result = await getAllProducts();
      
      if (result['success']) {
        List<ProductModel> products = result['data'];
        Set<String> categories = products.map((p) => p.kategori).toSet();
        return categories.toList()..sort();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get unique brands
  Future<List<String>> getBrands() async {
    try {
      final result = await getAllProducts();
      
      if (result['success']) {
        List<ProductModel> products = result['data'];
        Set<String> brands = products.map((p) => p.brand).toSet();
        return brands.toList()..sort();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }
}