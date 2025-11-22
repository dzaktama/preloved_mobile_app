// lib/view/halaman_utama.dart
import 'package:flutter/material.dart';
import '../controller/home_controller.dart';
import '../controller/controller_cart.dart';
import '../model/product_model.dart';
import 'package:preloved_mobile_app/view/profil/profile.dart';
import 'package:preloved_mobile_app/view/cart.dart';
import 'package:preloved_mobile_app/view/like.dart';
import 'package:preloved_mobile_app/view/transaksi/halaman_checkout.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController _controller = HomeController();
  final ControllerCart _controllerCart = ControllerCart();
  final TextEditingController _searchController = TextEditingController();
  
  // Favorites and Cart
  Set<String> favoriteProducts = {};
<<<<<<< HEAD
  Map<String, int> cartItems = {}; // productId: quantity
  
  // Colors
=======
  Map<String, int> cartItems = {};
  int _cartItemCount = 0;

>>>>>>> 4f0011c85ae1c236f9e2eca11ab99c59b344c94b
  static const Color primaryColor = Color(0xFFE84118);
  static const Color secondaryColor = Color(0xFFFF6348);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color textDark = Color(0xFF2F3640);
  static const Color textLight = Color(0xFF57606F);
  static const Color borderColor = Color(0xFFDFE4EA);
  static const Color successColor = Color(0xFF26A69A);

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadCart();
  }

  Future<void> _loadData() async {
    setState(() {});
    await _controller.loadInitialData();
    setState(() {});
  }

  Future<void> _loadCart() async {
    final cart = await _controllerCart.ambilSemuaCart();
    final count = await _controllerCart.hitungTotalItem();
    setState(() {
      cartItems = cart;
      _cartItemCount = count;
    });
  }

  Future<void> _refreshData() async {
    await _controller.refreshData();
    await _loadCart();
    setState(() {});
  }

  void _toggleFavorite(String productId) {
    setState(() {
      if (favoriteProducts.contains(productId)) {
        favoriteProducts.remove(productId);
        _showSnackBar('Removed from favorites', Icons.heart_broken);
      } else {
        favoriteProducts.add(productId);
        _showSnackBar('Added to favorites', Icons.favorite, isSuccess: true);
      }
    });
  }

  void _addToCart(ProductModel product) async {
    await _controllerCart.tambahKeCart(product.id, 1);
    await _loadCart();
    _showSnackBar('Added to cart', Icons.shopping_cart, isSuccess: true);
  }

  void _showSnackBar(String message, IconData icon, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: isSuccess ? successColor : textLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter & Sort',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _controller.clearFilters();
                      setState(() {});
                      setModalState(() {});
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: primaryColor,
                    ),
                    child: const Text('Clear All'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Categories
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _controller.categories.map((category) {
                  final isSelected = _controller.selectedCategory == category;
                  return ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      _controller.filterByCategory(category);
                      setState(() {});
                      setModalState(() {});
                    },
                    selectedColor: primaryColor,
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : textDark,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24),
              
              // Sort
              const Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 12),
              _buildSortOption('Default', 'default', setModalState),
              _buildSortOption('Price: Low to High', 'price_low_to_high', setModalState),
              _buildSortOption('Price: High to Low', 'price_high_to_low', setModalState),
              _buildSortOption('Name: A-Z', 'name_a_to_z', setModalState),
              _buildSortOption('Name: Z-A', 'name_z_to_a', setModalState),
              
              const SizedBox(height: 24),
              
              // Apply button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Apply Filter',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, String value, StateSetter setModalState) {
    final isSelected = _controller.selectedSort == value;
    return RadioListTile<String>(
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: textDark,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      value: value,
      groupValue: _controller.selectedSort,
      activeColor: primaryColor,
      onChanged: (val) {
        if (val != null) {
          _controller.sortProducts(val);
          setState(() {});
          setModalState(() {});
        }
      },
      contentPadding: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'PreLoved',
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          // Favorites
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.favorite_border, color: textDark),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FavoritesPage(
                        favoriteProducts: favoriteProducts,
                        allProducts: _controller.allProducts,
                        onToggleFavorite: _toggleFavorite,
                      ),
                    ),
                  );
                },
              ),
              if (favoriteProducts.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${favoriteProducts.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // Cart
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, color: textDark),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartPage(
                        cartItems: cartItems,
                        allProducts: _controller.allProducts,
                        onUpdateCart: (updatedCart) async {
                          await _loadCart();
                        },
                      ),
                    ),
                  );
                  await _loadCart();
                },
              ),
              if (_cartItemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_cartItemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // Profile
          IconButton(
            icon: const Icon(Icons.person_outline, color: textDark),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _controller.errorMessage.isNotEmpty
              ? _buildErrorWidget()
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  color: primaryColor,
                  child: CustomScrollView(
                    slivers: [
                      // Search bar
                      SliverToBoxAdapter(
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (value) async {
                                      await _controller.searchProducts(value);
                                      setState(() {});
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Search products...',
                                      hintStyle: TextStyle(
                                        color: textLight.withOpacity(0.6),
                                        fontSize: 14,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.search,
                                        color: textLight,
                                        size: 20,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              InkWell(
                                onTap: _showFilterSheet,
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryColor.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.tune,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Categories horizontal scroll
                      SliverToBoxAdapter(
                        child: Container(
                          height: 50,
                          color: Colors.white,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _controller.categories.length,
                            itemBuilder: (context, index) {
                              final category = _controller.categories[index];
                              final isSelected = _controller.selectedCategory == category;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(category),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    _controller.filterByCategory(category);
                                    setState(() {});
                                  },
                                  selectedColor: primaryColor,
                                  backgroundColor: backgroundColor,
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : textDark,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 8)),

                      // Product count
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            '${_controller.displayedProducts.length} products found',
                            style: const TextStyle(
                              fontSize: 14,
                              color: textLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      // Products grid
                      _controller.displayedProducts.isEmpty
                          ? const SliverFillRemaining(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.shopping_bag_outlined,
                                      size: 64,
                                      color: textLight,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No products found',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: textLight,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SliverPadding(
                              padding: const EdgeInsets.all(16),
                              sliver: SliverGrid(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
<<<<<<< HEAD
                                  childAspectRatio: 0.68,
=======
                                  childAspectRatio: 0.72,
>>>>>>> 4f0011c85ae1c236f9e2eca11ab99c59b344c94b
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    return _buildProductCard(
                                      _controller.displayedProducts[index],
                                    );
                                  },
                                  childCount: _controller.displayedProducts.length,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final isFavorite = favoriteProducts.contains(product.id);
    
    return InkWell(
      onTap: () {
        _showProductDetail(product);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
<<<<<<< HEAD
            // Product image with favorite button
=======
>>>>>>> 4f0011c85ae1c236f9e2eca11ab99c59b344c94b
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    product.linkGambar,
<<<<<<< HEAD
                    height: 140,
=======
                    height: 120,
>>>>>>> 4f0011c85ae1c236f9e2eca11ab99c59b344c94b
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 140,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, size: 40, color: textLight),
                      );
                    },
                  ),
                ),
                // Favorite button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _toggleFavorite(product.id),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isFavorite ? primaryColor : textLight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
<<<<<<< HEAD
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
=======
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
>>>>>>> 4f0011c85ae1c236f9e2eca11ab99c59b344c94b
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.brand,
                      style: const TextStyle(
<<<<<<< HEAD
                        fontSize: 10,
=======
                        fontSize: 9,
>>>>>>> 4f0011c85ae1c236f9e2eca11ab99c59b344c94b
                        color: textLight,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
<<<<<<< HEAD
                    
                    const SizedBox(height: 4),
                    
                    // Product name
                    Expanded(
                      child: Text(
                        product.namaBarang,
                        style: const TextStyle(
                          fontSize: 12,
=======
                    const SizedBox(height: 2),
                    Flexible(
                      child: Text(
                        product.namaBarang,
                        style: const TextStyle(
                          fontSize: 11,
>>>>>>> 4f0011c85ae1c236f9e2eca11ab99c59b344c94b
                          fontWeight: FontWeight.w600,
                          color: textDark,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
<<<<<<< HEAD
                    
                    const SizedBox(height: 6),
                    
                    // Price
                    Text(
                      product.harga,
                      style: const TextStyle(
                        fontSize: 14,
=======
                    const SizedBox(height: 4),
                    Text(
                      product.harga,
                      style: const TextStyle(
                        fontSize: 12,
>>>>>>> 4f0011c85ae1c236f9e2eca11ab99c59b344c94b
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
<<<<<<< HEAD
                    
                    const SizedBox(height: 6),
                    
                    // Condition
=======
                    const SizedBox(height: 4),
>>>>>>> 4f0011c85ae1c236f9e2eca11ab99c59b344c94b
                    Row(
                      children: [
                        Icon(Icons.star, size: 11, color: Colors.amber[700]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            product.kondisi,
                            style: const TextStyle(
<<<<<<< HEAD
                              fontSize: 10,
=======
                              fontSize: 9,
>>>>>>> 4f0011c85ae1c236f9e2eca11ab99c59b344c94b
                              color: textLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: textLight,
            ),
            const SizedBox(height: 16),
            Text(
              _controller.errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: textLight,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetail(ProductModel product) {
    final isFavorite = favoriteProducts.contains(product.id);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    controller: controller,
                    padding: const EdgeInsets.all(24),
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Product image with favorite
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              product.linkGambar,
                              height: 300,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 300,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 300,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image_not_supported, size: 56, color: Colors.grey),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: GestureDetector(
                              onTap: () {
                                _toggleFavorite(product.id);
                                setModalState(() {});
                                setState(() {});
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  size: 24,
                                  color: isFavorite ? primaryColor : textLight,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Brand & Category
                      Row(
                        children: [
                          Chip(
                            label: Text(product.brand),
                            backgroundColor: primaryColor.withOpacity(0.1),
                            labelStyle: const TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(product.kategori),
                            backgroundColor: Colors.grey[200],
                            labelStyle: const TextStyle(
                              color: textDark,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Product name
                      Text(
                        product.namaBarang,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Price
                      Text(
                        product.harga,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Details
                      _buildDetailRow('Condition', product.kondisi),
                      _buildDetailRow('Size', product.ukuran),
                      _buildDetailRow('Material', product.bahan),
                      _buildDetailRow('Location', product.lokasi),
                      
                      const SizedBox(height: 24),
                      
                      // Description
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.deskripsi,
                        style: const TextStyle(
                          fontSize: 14,
                          color: textLight,
                          height: 1.6,
                        ),
                      ),
                      
                      const SizedBox(height: 100), // Space for bottom buttons
                    ],
                  ),
                ),
                
                // Bottom action buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Add to Cart button
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _addToCart(product);
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                            label: const Text(
                              'Add to Cart',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryColor,
                              side: const BorderSide(color: primaryColor, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Buy Now button
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context); // Tutup modal detail
                              
                              // Buat temporary cart dengan 1 item product ini
                              Map<String, int> checkoutItems = {product.id: 1};
                              
                              // Navigate ke CheckoutPage
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CheckoutPage(
                                    cartItems: checkoutItems,
                                    allProducts: _controller.allProducts,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.shopping_bag, size: 20),
                            label: const Text(
                              'Buy Now',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}