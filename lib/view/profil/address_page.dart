import 'package:flutter/material.dart';
import '../../controller/controller_address.dart';
import '../../controller/auth_controller.dart';
import '../../model/address_model.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({Key? key}) : super(key: key);

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final AddressController _addressController = AddressController();
  final AuthController _authController = AuthController();
  
  List<AddressModel> _daftarAlamat = [];
  bool _isLoading = true;
  String? _userId;

  static const Color primaryColor = Color(0xFFE84118);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color textDark = Color(0xFF2F3640);
  static const Color textLight = Color(0xFF57606F);
  static const Color borderColor = Color(0xFFDFE4EA);

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() => _isLoading = true);
    
    final user = await _authController.getUserLogin();
    if (user != null && user.key != null) {
      _userId = user.key.toString();
      final addresses = await _addressController.ambilAlamatUser(_userId!);
      setState(() {
        _daftarAlamat = addresses;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddEditBottomSheet({AddressModel? address}) async {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController(text: address?.namaLengkap);
    final teleponController = TextEditingController(text: address?.nomorTelepon);
    final alamatController = TextEditingController(text: address?.alamatLengkap);
    final kotaController = TextEditingController(text: address?.kota);
    final provinsiController = TextEditingController(text: address?.provinsi);
    final kodePosController = TextEditingController(text: address?.kodePos);
    String selectedLabel = address?.label ?? 'Rumah';
    bool isPrimary = address?.isPrimary ?? false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.92,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) => StatefulBuilder(
            builder: (context, setSheetState) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    padding: const EdgeInsets.all(16),
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
                              address == null ? 'Tambah Alamat' : 'Edit Alamat',
                              style: const TextStyle(
                                fontSize: 20,
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
                  
                  // Form content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: controller,
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: namaController,
                              decoration: _inputDecoration('Nama Lengkap', Icons.person_outline),
                              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                            ),
                            const SizedBox(height: 16),
                            
                            TextFormField(
                              controller: teleponController,
                              decoration: _inputDecoration('Nomor Telepon', Icons.phone_outlined),
                              keyboardType: TextInputType.phone,
                              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                            ),
                            const SizedBox(height: 16),
                            
                            TextFormField(
                              controller: alamatController,
                              decoration: _inputDecoration('Alamat Lengkap', Icons.location_on_outlined),
                              maxLines: 3,
                              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                            ),
                            const SizedBox(height: 16),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: kotaController,
                                    decoration: _inputDecoration('Kota', Icons.location_city),
                                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: kodePosController,
                                    decoration: _inputDecoration('Kode Pos', Icons.markunread_mailbox),
                                    keyboardType: TextInputType.number,
                                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            TextFormField(
                              controller: provinsiController,
                              decoration: _inputDecoration('Provinsi', Icons.map_outlined),
                              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                            ),
                            const SizedBox(height: 16),
                            
                            const Text(
                              'Label Alamat',
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
                              children: ['Rumah', 'Kantor', 'Apartemen', 'Lainnya'].map((label) {
                                final isSelected = selectedLabel == label;
                                return ChoiceChip(
                                  label: Text(label),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setSheetState(() {
                                      selectedLabel = label;
                                    });
                                  },
                                  selectedColor: primaryColor,
                                  backgroundColor: backgroundColor,
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : textDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              }).toList(),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            Container(
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              child: CheckboxListTile(
                                value: isPrimary,
                                title: const Text(
                                  'Jadikan alamat utama',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: const Text(
                                  'Alamat ini akan digunakan sebagai default',
                                  style: TextStyle(fontSize: 12),
                                ),
                                activeColor: primaryColor,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                onChanged: (value) {
                                  setSheetState(() {
                                    isPrimary = value!;
                                  });
                                },
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Bottom button
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
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final newAddress = AddressModel(
                                idAddress: address?.idAddress,
                                idUser: _userId,
                                namaLengkap: namaController.text,
                                nomorTelepon: teleponController.text,
                                alamatLengkap: alamatController.text,
                                kota: kotaController.text,
                                provinsi: provinsiController.text,
                                kodePos: kodePosController.text,
                                label: selectedLabel,
                                isPrimary: isPrimary,
                              );

                              bool success;
                              if (address == null) {
                                success = await _addressController.tambahAlamat(newAddress);
                              } else {
                                success = await _addressController.updateAlamat(newAddress);
                              }

                              if (success && mounted) {
                                Navigator.pop(context);
                                _loadAddresses();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(address == null
                                        ? 'Alamat berhasil ditambahkan'
                                        : 'Alamat berhasil diperbarui'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            address == null ? 'Simpan Alamat' : 'Update Alamat',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
          onPressed: () => Navigator.pop(context, true),
        ),
        title: const Text(
          'Alamat Saya',
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _daftarAlamat.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off_outlined,
                        size: 80,
                        color: textLight.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum ada alamat',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tambahkan alamat pengiriman Anda',
                        style: TextStyle(
                          fontSize: 14,
                          color: textLight,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _daftarAlamat.length,
                  itemBuilder: (context, index) {
                    return _buildAddressCard(_daftarAlamat[index]);
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditBottomSheet(),
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Alamat'),
      ),
    );
  }

  Widget _buildAddressCard(AddressModel address) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: address.isPrimary == true
            ? Border.all(color: primaryColor, width: 2)
            : null,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        address.label ?? 'Rumah',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    if (address.isPrimary == true) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Utama',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    if (address.isPrimary != true)
                      const PopupMenuItem(
                        value: 'primary',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, size: 20),
                            SizedBox(width: 8),
                            Text('Jadikan Utama'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Hapus', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'edit') {
                      _showAddEditBottomSheet(address: address);
                    } else if (value == 'primary') {
                      await _addressController.setPrimaryAddress(
                          _userId!, address.idAddress!);
                      _loadAddresses();
                    } else if (value == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text('Hapus Alamat'),
                          content: const Text(
                              'Yakin ingin menghapus alamat ini?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Batal'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Hapus'),
                            ),
                          ],
                        ),
                      );
                      
                      if (confirm == true) {
                        await _addressController.hapusAlamat(address);
                        _loadAddresses();
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              address.namaLengkap ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              address.nomorTelepon ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: textLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              address.alamatLengkap ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: textDark,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${address.kota}, ${address.provinsi} ${address.kodePos}',
              style: const TextStyle(
                fontSize: 14,
                color: textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: textLight, size: 20),
      labelStyle: const TextStyle(color: textLight, fontSize: 14),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: backgroundColor,
    );
  }
}