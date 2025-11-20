// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/product_model.dart';

class ApiService {
  // Base URL API
  static const String baseUrl = 'https://api-preloved-ydhf.vercel.app';
  
  // Endpoint
  static const String productsEndpoint = '/data_barang.json';

  // ==================== GET ALL PRODUCTS ====================
  Future<Map<String, dynamic>> getAllProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$productsEndpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Connection timeout. Please try again.');
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final productResponse = ProductResponse.fromJson(jsonData);

        return {
          'success': true,
          'message': 'Products loaded successfully',
          'data': productResponse.dataBarang,
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Products not found',
          'data': <ProductModel>[],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load products. Status code: ${response.statusCode}',
          'data': <ProductModel>[],
        };
      }
    } on http.ClientException catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.message}',
        'data': <ProductModel>[],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: $e',
        'data': <ProductModel>[],
      };
    }
  }

  // ==================== SEARCH PRODUCTS ====================
  Future<Map<String, dynamic>> searchProducts(String query) async {
    try {
      final result = await getAllProducts();
      
      if (result['success']) {
        List<ProductModel> allProducts = result['data'];
        
        // Filter products based on query
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

  // ==================== FILTER BY CATEGORY ====================
  Future<Map<String, dynamic>> filterByCategory(String category) async {
    try {
      final result = await getAllProducts();
      
      if (result['success']) {
        List<ProductModel> allProducts = result['data'];
        
        // Filter by category
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

  // ==================== SORT PRODUCTS ====================
  List<ProductModel> sortProducts(
    List<ProductModel> products,
    String sortBy,
  ) {
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
      default:
        // No sorting
        break;
    }

    return sortedProducts;
  }

  // ==================== GET UNIQUE CATEGORIES ====================
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

  // ==================== GET UNIQUE BRANDS ====================
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