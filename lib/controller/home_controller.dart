// lib/controllers/home_controller.dart
import 'package:flutter/material.dart';
import '../model/product_model.dart';
import '../services/layanan_api.dart';

class HomeController {
  final ApiService _apiService = ApiService();

  // State management variables
  List<ProductModel> allProducts = [];
  List<ProductModel> displayedProducts = [];
  List<String> categories = [];
  List<String> brands = [];
  String selectedCategory = 'All';
  String selectedSort = 'default';
  bool isLoading = false;
  String errorMessage = '';

  // ==================== LOAD ALL DATA ====================
  Future<Map<String, dynamic>> loadInitialData() async {
    try {
      isLoading = true;
      errorMessage = '';

      // Load products
      final productResult = await _apiService.getAllProducts();
      
      if (productResult['success']) {
        allProducts = productResult['data'];
        displayedProducts = List.from(allProducts);

        // Load categories
        categories = await _apiService.getCategories();
        categories.insert(0, 'All'); // Add "All" option

        // Load brands
        brands = await _apiService.getBrands();

        isLoading = false;

        return {
          'success': true,
          'message': 'Data loaded successfully',
        };
      } else {
        isLoading = false;
        errorMessage = productResult['message'];
        
        return {
          'success': false,
          'message': productResult['message'],
        };
      }
    } catch (e) {
      isLoading = false;
      errorMessage = 'Failed to load data: $e';
      
      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }

  // ==================== SEARCH PRODUCTS ====================
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      displayedProducts = List.from(allProducts);
      _applyCurrentFilters();
      return;
    }

    final result = await _apiService.searchProducts(query);
    
    if (result['success']) {
      displayedProducts = result['data'];
      _applyCurrentFilters();
    }
  }

  // ==================== FILTER BY CATEGORY ====================
  void filterByCategory(String category) {
    selectedCategory = category;
    
    if (category == 'All') {
      displayedProducts = List.from(allProducts);
    } else {
      displayedProducts = allProducts
          .where((product) => product.kategori == category)
          .toList();
    }
    
    _applySorting();
  }

  // ==================== SORT PRODUCTS ====================
  void sortProducts(String sortBy) {
    selectedSort = sortBy;
    _applySorting();
  }

  // ==================== PRIVATE METHODS ====================
  void _applyCurrentFilters() {
    // Apply category filter
    if (selectedCategory != 'All') {
      displayedProducts = displayedProducts
          .where((product) => product.kategori == selectedCategory)
          .toList();
    }
    
    // Apply sorting
    _applySorting();
  }

  void _applySorting() {
    displayedProducts = _apiService.sortProducts(displayedProducts, selectedSort);
  }

  // ==================== GET PRODUCTS BY CATEGORY ====================
  List<ProductModel> getProductsByCategory(String category) {
    if (category == 'All') {
      return allProducts;
    }
    return allProducts.where((p) => p.kategori == category).toList();
  }

  // ==================== GET FEATURED PRODUCTS ====================
  List<ProductModel> getFeaturedProducts({int limit = 6}) {
    // Return first N products or random products
    if (allProducts.length <= limit) {
      return allProducts;
    }
    return allProducts.sublist(0, limit);
  }

  // ==================== GET CATEGORIES WITH COUNTS ====================
  Map<String, int> getCategoriesWithCount() {
    Map<String, int> categoryCount = {};
    
    for (var product in allProducts) {
      categoryCount[product.kategori] = (categoryCount[product.kategori] ?? 0) + 1;
    }
    
    return categoryCount;
  }

  // ==================== REFRESH DATA ====================
  Future<Map<String, dynamic>> refreshData() async {
    return await loadInitialData();
  }

  // ==================== CLEAR FILTERS ====================
  void clearFilters() {
    selectedCategory = 'All';
    selectedSort = 'default';
    displayedProducts = List.from(allProducts);
  }
}