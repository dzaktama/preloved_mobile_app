import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../model/product_model.dart';
import '../../model/transaksi_model.dart';
import '../../model/address_model.dart';
import '../../model/userModel.dart';
import '../../controller/controller_transaksi.dart';
import '../../controller/controller_address.dart';
import '../../controller/auth_controller.dart';
import '../profil/address_page.dart';

class CheckoutPage extends StatefulWidget {
  final Map<String, int> cartItems;
  final List<ProductModel> allProducts;

  const CheckoutPage({
    Key? key,
    required this.cartItems,
    required this.allProducts,
  }) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  static const Color primaryColor = Color(0xFFE84118);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color textDark = Color(0xFF2F3640);
  static const Color textLight = Color(0xFF57606F);
  static const Color borderColor = Color(0xFFDFE4EA);
  static const Color successColor = Color(0xFF26A69A);

  final AuthController _authController = AuthController();
  final AddressController _addressController = AddressController();
  final ControllerTransaksi _controllerTransaksi = ControllerTransaksi();
  
  UserModel? _currentUser;
  AddressModel? _selectedAddress;
  bool _isLoading = true;
  
  final _notesController = TextEditingController();

  String _selectedPayment = 'COD';
  String _selectedShipping = 'Regular';

  final List<Map<String, dynamic>> _paymentMethods = [
    {'id': 'COD', 'name': 'Cash on Delivery', 'icon': Icons.money},
    {'id': 'Transfer', 'name': 'Bank Transfer', 'icon': Icons.account_balance},
    {'id': 'E-Wallet', 'name': 'E-Wallet', 'icon': Icons.wallet},
  ];

  final List<Map<String, dynamic>> _shippingMethods = [
    {'id': 'Regular', 'name': 'Regular', 'duration': '3-5 days', 'price': 15000},
    {'id': 'Express', 'name': 'Express', 'duration': '1-2 days', 'price': 25000},
    {'id': 'Same Day', 'name': 'Same Day', 'duration': 'Today', 'price': 35000},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    final user = await _authController.getUserLogin();
    if (user != null && user.key != null) {
      final primaryAddress = await _addressController.ambilPrimaryAddress(user.key.toString());
      setState(() {
        _currentUser = user;
        _selectedAddress = primaryAddress;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _navigateToAddressPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddressPage(),
      ),
    );
    
    // Reload address setelah kembali dari address page
    if (result == true || result == null) {
      _loadUserData();
    }
  }

  double _calculateSubtotal() {
    double total = 0;
    for (var entry in widget.cartItems.entries) {
      final product = widget.allProducts.firstWhere(
        (p) => p.id == entry.key,
        orElse: () => widget.allProducts.first,
      );
      final priceString = product.harga.replaceAll(RegExp(r'[^0-9]'), '');
      final price = double.tryParse(priceString) ?? 0;
      total += price * entry.value;
    }
    return total;
  }

  double _getShippingCost() {
    return _shippingMethods
        .firstWhere((method) => method['id'] == _selectedShipping)['price']
        .toDouble();
  }

  double _calculateTotal() {
    return _calculateSubtotal() + _getShippingCost();
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  void _processCheckout() {
    // Validasi alamat
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add your shipping address first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
            SizedBox(height: 20),
            Text(
              'Processing your order...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () async {
      await _simpanTransaksi();
      
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      _showSuccessDialog();
    });
  }

  Future<void> _simpanTransaksi() async {
    List<ItemTransaksi> items = [];
    for (var entry in widget.cartItems.entries) {
      final product = widget.allProducts.firstWhere(
        (p) => p.id == entry.key,
        orElse: () => widget.allProducts.first,
      );
      
      final priceString = product.harga.replaceAll(RegExp(r'[^0-9]'), '');
      final price = double.tryParse(priceString) ?? 0;
      
      items.add(ItemTransaksi(
        idProduk: product.id,
        namaProduk: product.namaBarang,
        brand: product.brand,
        harga: price,
        jumlah: entry.value,
        gambar: product.linkGambar,
      ));
    }

    final alamatLengkap = '${_selectedAddress!.alamatLengkap}, ${_selectedAddress!.kota}, ${_selectedAddress!.provinsi} ${_selectedAddress!.kodePos}';

    final transaksi = TransaksiModel(
      idTransaksi: 'TRX${DateTime.now().millisecondsSinceEpoch}',
      idUser: _currentUser?.key.toString() ?? 'guest',
      items: items,
      totalHarga: _calculateSubtotal(),
      ongkir: _getShippingCost(),
      status: 'Pending',
      tanggalTransaksi: DateTime.now(),
      metodePembayaran: _selectedPayment,
      alamatPengiriman: alamatLengkap,
    );

    await _controllerTransaksi.simpanTransaksi(transaksi);
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: successColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: successColor,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Order Successful!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your order has been placed successfully.\nWe will contact you soon!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: textLight,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, true);
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
                  'Back to Home',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
          'Checkout',
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Order Summary
                _buildSectionCard(
                  title: 'Order Summary',
                  icon: Icons.shopping_bag_outlined,
                  child: Column(
                    children: widget.cartItems.entries.map((entry) {
                      final product = widget.allProducts.firstWhere(
                        (p) => p.id == entry.key,
                        orElse: () => widget.allProducts.first,
                      );
                      return _buildOrderItem(product, entry.value);
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // Shipping Address (dari Address Model)
                _buildSectionCard(
                  title: 'Shipping Address',
                  icon: Icons.location_on,
                  child: _selectedAddress != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _selectedAddress!.label ?? 'Rumah',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (_selectedAddress!.isPrimary == true)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Primary',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _selectedAddress!.namaLengkap ?? '',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _selectedAddress!.nomorTelepon ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: textLight,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _selectedAddress!.alamatLengkap ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: textDark,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_selectedAddress!.kota}, ${_selectedAddress!.provinsi} ${_selectedAddress!.kodePos}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: textLight,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _navigateToAddressPage,
                                icon: const Icon(Icons.edit_location_alt, size: 18),
                                label: const Text('Change Address'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryColor,
                                  side: const BorderSide(color: primaryColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Icon(
                              Icons.location_off,
                              size: 48,
                              color: textLight.withOpacity(0.5),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No address found',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Please add your shipping address',
                              style: TextStyle(
                                fontSize: 12,
                                color: textLight,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _navigateToAddressPage,
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Add Address'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),

                const SizedBox(height: 16),

                // Notes (Optional)
                _buildSectionCard(
                  title: 'Order Notes (Optional)',
                  icon: Icons.note_outlined,
                  child: TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Add notes for seller...',
                      hintStyle: TextStyle(color: textLight.withOpacity(0.6)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: primaryColor, width: 2),
                      ),
                      filled: true,
                      fillColor: backgroundColor,
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Shipping Method
                _buildSectionCard(
                  title: 'Shipping Method',
                  icon: Icons.local_shipping,
                  child: Column(
                    children: _shippingMethods.map((method) {
                      return _buildShippingOption(method);
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // Payment Method
                _buildSectionCard(
                  title: 'Payment Method',
                  icon: Icons.payment,
                  child: Column(
                    children: _paymentMethods.map((method) {
                      return _buildPaymentOption(method);
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // Price Summary
                _buildSectionCard(
                  title: 'Price Details',
                  icon: Icons.receipt_long,
                  child: Column(
                    children: [
                      _buildPriceRow('Subtotal', _formatCurrency(_calculateSubtotal())),
                      const SizedBox(height: 12),
                      _buildPriceRow('Shipping Cost', _formatCurrency(_getShippingCost())),
                      const Divider(height: 24),
                      _buildPriceRow('Total', _formatCurrency(_calculateTotal()), isTotal: true),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),

          // Bottom Button
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Payment',
                        style: TextStyle(
                          fontSize: 14,
                          color: textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatCurrency(_calculateTotal()),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _processCheckout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Place Order',
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

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: primaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(ProductModel product, int quantity) {
    final priceString = product.harga.replaceAll(RegExp(r'[^0-9]'), '');
    final price = double.tryParse(priceString) ?? 0;
    final total = price * quantity;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product.linkGambar,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
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
                  'Qty: $quantity',
                  style: const TextStyle(
                    fontSize: 12,
                    color: textLight,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatCurrency(total),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingOption(Map<String, dynamic> method) {
    final isSelected = _selectedShipping == method['id'];
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedShipping = method['id'];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? primaryColor : textLight,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method['name'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? primaryColor : textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    method['duration'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: textLight,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _formatCurrency(method['price'].toDouble()),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? primaryColor : textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(Map<String, dynamic> method) {
    final isSelected = _selectedPayment == method['id'];
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPayment = method['id'];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? primaryColor : textLight,
              size: 22,
            ),
            const SizedBox(width: 12),
            Icon(
              method['icon'],
              color: isSelected ? primaryColor : textLight,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              method['name'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? primaryColor : textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? textDark : textLight,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal ? primaryColor : textDark,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}