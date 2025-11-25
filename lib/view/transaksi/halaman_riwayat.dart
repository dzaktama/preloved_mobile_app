import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../controller/controller_transaksi.dart';
import '../../controller/auth_controller.dart';
import '../../model/transaksi_model.dart';

class HalamanRiwayat extends StatefulWidget {
  const HalamanRiwayat({super.key});

  @override
  State<HalamanRiwayat> createState() => _HalamanRiwayatState();
}

class _HalamanRiwayatState extends State<HalamanRiwayat> {
  final ControllerTransaksi _controllerTransaksi = ControllerTransaksi();
  final AuthController _authController = AuthController();
  
  List<TransaksiModel> _daftarTransaksi = [];
  bool _isLoading = true;
  String _filterStatus = 'All';

  static const Color primaryColor = Color(0xFFE84118);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color textDark = Color(0xFF2F3640);
  static const Color textLight = Color(0xFF57606F);
  static const Color borderColor = Color(0xFFDFE4EA);

  @override
  void initState() {
    super.initState();
    _muatDataTransaksi();
  }

  Future<void> _muatDataTransaksi() async {
    setState(() => _isLoading = true);
    
    final user = await _authController.getUserLogin();
    if (user != null && user.id != null) {
      final transaksi = await _controllerTransaksi.ambilTransaksiByUser(user.id!);
      setState(() {
        _daftarTransaksi = transaksi;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  List<TransaksiModel> get _transaksiTerfilter {
    if (_filterStatus == 'All') {
      return _daftarTransaksi;
    }
    return _daftarTransaksi.where((t) => t.status == _filterStatus).toList();
  }

  // FIX: Helper method untuk format tanggal dengan safe parsing
  String _formatTanggal(TransaksiModel transaksi) {
    try {
      final tanggalDateTime = transaksi.tanggalDateTime;
      if (tanggalDateTime != null) {
        return DateFormat('dd MMM yyyy, HH:mm').format(tanggalDateTime);
      }
      return 'No date';
    } catch (e) {
      return 'Invalid date';
    }
  }

  String _formatTanggalLengkap(TransaksiModel transaksi) {
    try {
      final tanggalDateTime = transaksi.tanggalDateTime;
      if (tanggalDateTime != null) {
        return DateFormat('dd MMMM yyyy, HH:mm').format(tanggalDateTime);
      }
      return 'No date';
    } catch (e) {
      return 'Invalid date';
    }
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
          'Order History',
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Pending'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Processing'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Completed'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Cancelled'),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _transaksiTerfilter.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.receipt_long_outlined,
                                size: 80,
                                color: Color(0x8057606F),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No orders yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: textDark,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Your order history will appear here',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textLight.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _muatDataTransaksi,
                          color: primaryColor,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _transaksiTerfilter.length,
                            itemBuilder: (context, index) {
                              return _buildOrderCard(_transaksiTerfilter[index]);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filterStatus == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = label;
        });
      },
      selectedColor: primaryColor,
      backgroundColor: backgroundColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : textDark,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  Widget _buildOrderCard(TransaksiModel transaksi) {
    final statusColor = _getStatusColor(transaksi.status ?? 'Pending');
    // FIX: Gunakan helper method untuk format tanggal
    final tanggal = _formatTanggal(transaksi);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDetailTransaksi(transaksi),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${transaksi.idTransaksi ?? '-'}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        transaksi.status ?? 'Pending',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  tanggal,
                  style: const TextStyle(
                    fontSize: 12,
                    color: textLight,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: borderColor),
                const SizedBox(height: 12),
                
                ...((transaksi.items ?? []).take(2).map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.gambar ?? '',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[200],
                                child: const Icon(Icons.image, size: 24),
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
                                item.namaProduk ?? '-',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: textDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.jumlah}x ${_formatHarga(item.harga ?? 0)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList()),
                
                if ((transaksi.items?.length ?? 0) > 2)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+${(transaksi.items?.length ?? 0) - 2} more items',
                      style: const TextStyle(
                        fontSize: 12,
                        color: textLight,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                
                const SizedBox(height: 12),
                const Divider(height: 1, color: borderColor),
                const SizedBox(height: 12),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textDark,
                      ),
                    ),
                    Text(
                      _formatHarga(transaksi.grandTotal),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'Processing':
        return Colors.orange;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _formatHarga(double harga) {
    return 'Rp ${harga.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  void _showDetailTransaksi(TransaksiModel transaksi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
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
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order Details #${transaksi.idTransaksi ?? '-'}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('Order ID', transaksi.idTransaksi ?? '-'),
                          const Divider(height: 24),
                          // FIX: Gunakan helper method untuk format tanggal lengkap
                          _buildInfoRow('Date', _formatTanggalLengkap(transaksi)),
                          const Divider(height: 24),
                          _buildInfoRow('Status', transaksi.status ?? 'Pending'),
                          const Divider(height: 24),
                          _buildInfoRow('Payment', transaksi.metodePembayaran ?? '-'),
                          const Divider(height: 24),
                          _buildInfoRow('Address', transaksi.alamatPengiriman ?? '-'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Items',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    ...((transaksi.items ?? []).map((item) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.gambar ?? '',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.image, size: 30),
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
                                    item.namaProduk ?? '-',
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
                                    item.brand ?? '',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: textLight,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${item.jumlah}x ${_formatHarga(item.harga ?? 0)}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: textLight,
                                        ),
                                      ),
                                      Text(
                                        _formatHarga(item.subtotal),
                                        style: const TextStyle(
                                          fontSize: 14,
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
                      );
                    }).toList()),
                    
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Subtotal',
                                style: TextStyle(fontSize: 14, color: textLight),
                              ),
                              Text(
                                _formatHarga(transaksi.totalHarga ?? 0),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: textDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Shipping',
                                style: TextStyle(fontSize: 14, color: textLight),
                              ),
                              Text(
                                _formatHarga(transaksi.ongkir ?? 0),
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
                                _formatHarga(transaksi.grandTotal),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: textLight,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}