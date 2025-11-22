// lib/views/cart_page.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../model/product_model.dart';
import '../controller/controller_transaksi.dart';
import '../model/transaksi_model.dart';

class CartPage extends StatefulWidget {
  final Map<String, int> cartItems;
  final List<ProductModel> allProducts;
  final Function(Map<String, int>) onUpdateCart;

  const CartPage({
  super.key,
  required this.cartItems,
  required this.allProducts,
  required this.onUpdateCart,
});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  static const Color primaryColor = Color(0xFFE84118);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color textDark = Color(0xFF2F3640);
  static const Color textLight = Color(0xFF57606F);
  static const Color borderColor = Color(0xFFDFE4EA); // TAMBAHKAN INI
  static const Color successColor = Color(0xFF26A69A);

  late Map<String, int> localCartItems;

  @override
  void initState() {
    super.initState();
    localCartItems = Map.from(widget.cartItems);
  }

  void _updateQuantity(String productId, int change) {
    setState(() {
      if (localCartItems.containsKey(productId)) {
        int newQty = localCartItems[productId]! + change;
        if (newQty > 0) {
          localCartItems[productId] = newQty;
        } else {
          localCartItems.remove(productId);
        }
      }
    });
    widget.onUpdateCart(localCartItems);
  }

  void _removeItem(String productId) {
    setState(() {
      localCartItems.remove(productId);
    });
    widget.onUpdateCart(localCartItems);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text('Item removed from cart'),
          ],
        ),
        backgroundColor: successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  double _calculateTotal() {
    double total = 0;
    for (var entry in localCartItems.entries) {
      final product = widget.allProducts.firstWhere(
        (p) => p.id == entry.key,
        orElse: () => ProductModel(
          namaBarang: '',
          brand: '',
          kategori: '',
          harga: 'Rp 0',
          kondisi: '',
          ukuran: '',
          bahan: '',
          lokasi: '',
          linkGambar: '',
          deskripsi: '',
          kontakPenjual: '', // TAMBAHKAN INI
        ),
      );
      
      // Extract price number from string (e.g., "Rp 150.000" -> 150000)
      final priceStr = product.harga.replaceAll(RegExp(r'[^\d]'), '');
      final price = double.tryParse(priceStr) ?? 0;
      total += price * entry.value;
    }
    return total;
  }

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Shopping Cart',
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          if (localCartItems.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  localCartItems.clear();
                });
                widget.onUpdateCart(localCartItems);
              },
              icon: const Icon(Icons.delete_outline, size: 20),
              label: const Text('Clear'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
        ],
      ),
      body: localCartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: textLight.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add items to get started',
                    style: TextStyle(
                      fontSize: 14,
                      color: textLight,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Start Shopping',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: localCartItems.length,
                    itemBuilder: (context, index) {
                      final productId = localCartItems.keys.elementAt(index);
                      final quantity = localCartItems[productId]!;
                      final product = widget.allProducts.firstWhere(
                        (p) => p.id == productId,
                        orElse: () => ProductModel(
                          namaBarang: 'Unknown Product',
                          brand: '',
                          kategori: '',
                          harga: 'Rp 0',
                          kondisi: '',
                          ukuran: '',
                          bahan: '',
                          lokasi: '',
                          linkGambar: '',
                          deskripsi: '',
                          kontakPenjual: '', // TAMBAHKAN INI
                        ),
                      );

                      return Dismissible(
                        key: Key(productId),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          _removeItem(productId);
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
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
                          child: Row(
                            children: [
                              // Product image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  product.linkGambar,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.image),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              
                              // Product details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.namaBarang,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: textDark,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      product.brand,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: textLight,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      product.harga,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Quantity controls
                              Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: borderColor),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        InkWell(
                                          onTap: () => _updateQuantity(productId, -1),
                                          child: Container(
                                            width: 32,
                                            height: 32,
                                            alignment: Alignment.center,
                                            child: const Icon(
                                              Icons.remove,
                                              size: 16,
                                              color: textDark,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 40,
                                          height: 32,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            border: Border.symmetric(
                                              vertical: BorderSide(color: borderColor),
                                            ),
                                          ),
                                          child: Text(
                                            '$quantity',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: textDark,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () => _updateQuantity(productId, 1),
                                          child: Container(
                                            width: 32,
                                            height: 32,
                                            alignment: Alignment.center,
                                            child: const Icon(
                                              Icons.add,
                                              size: 16,
                                              color: textDark,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Bottom checkout section
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
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Total items
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Items (${localCartItems.values.reduce((a, b) => a + b)})',
                              style: TextStyle(
                                fontSize: 14,
                                color: textLight,
                              ),
                            ),
                            Text(
                              _formatPrice(_calculateTotal()),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Shipping (example)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Shipping',
                              style: TextStyle(
                                fontSize: 14,
                                color: textLight,
                              ),
                            ),
                            Text(
                              'Rp 15.000',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textDark,
                              ),
                            ),
                          ],
                        ),
                        
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1),
                        ),
                        
                        // Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textDark,
                              ),
                            ),
                            Text(
                              _formatPrice(_calculateTotal() + 15000),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Checkout button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              _showCheckoutDialog();
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
                              'Proceed to Checkout',
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
              ],
            ),
    );
  }

 void _showCheckoutDialog() async {
  final sessionBox = await Hive.openBox('box_session');
  final idUser = sessionBox.get('id_user');
  
  if (idUser == null) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please login first')),
    );
    return;
  }

  final controller = ControllerTransaksi();
  final items = localCartItems.entries.map((entry) {
    final product = widget.allProducts.firstWhere((p) => p.id == entry.key);
    return ItemTransaksi(
      idProduk: product.id,
      namaProduk: product.namaBarang,
      jumlah: entry.value,
      harga: product.hargaInt.toDouble(),
      gambar: product.linkGambar,
      brand: product.brand,
    );
  }).toList();

  final transaksi = TransaksiModel(
    idTransaksi: DateTime.now().millisecondsSinceEpoch.toString(),
    idUser: idUser.toString(),
    tanggalTransaksi: DateTime.now(),
    items: items,
    totalHarga: _calculateTotal(),
    ongkir: 15000,
    status: 'Pending',
    metodePembayaran: 'COD',
    alamatPengiriman: 'Alamat Default',
  );

  bool berhasil = await controller.simpanTransaksi(transaksi);

  if (!mounted) return;

  if (berhasil) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: successColor, size: 28),
            SizedBox(width: 12),
            Text(
              'Order Confirmed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your order has been placed successfully!',
              style: TextStyle(
                fontSize: 14,
                color: textLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount:'),
                      Text(
                        _formatPrice(_calculateTotal() + 15000),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('View Order'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                localCartItems.clear();
              });
              widget.onUpdateCart(localCartItems);
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text('Failed to save transaction'),
          ],
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}

}