// Path: lib/view/jual/halaman_tambah.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../controller/controller_barang.dart';
import '../../model/barang_model.dart';
import '../../controller/auth_controller.dart';
import '../my_items_page.dart';

class HalamanTambahBarang extends StatefulWidget {
  const HalamanTambahBarang({super.key});

  @override
  State<HalamanTambahBarang> createState() => _HalamanTambahBarangState();
}

class _HalamanTambahBarangState extends State<HalamanTambahBarang> {
  final _formKey = GlobalKey<FormState>();
  final ControllerBarang _controller = ControllerBarang();
  final AuthController _authController = AuthController();

  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _brandController = TextEditingController();
  final _bahanController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _kontakController = TextEditingController();

  String? _pathGambar;
  String _kategoriDipilih = 'Pakaian';
  String _kondisiDipilih = 'Baru';
  String _ukuranDipilih = 'M';

  bool _isLoading = false;

  static const Color primaryColor = Color(0xFFE84118);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color textDark = Color(0xFF2F3640);
  static const Color textLight = Color(0xFF57606F);
  static const Color borderColor = Color(0xFFDFE4EA);

  final List<String> _kategoriList = [
    'Pakaian',
    'Sepatu',
    'Aksesoris',
    'Tas',
    'Jam Tangan',
    'Lainnya'
  ];
  final List<String> _kondisiList = [
    'Baru',
    'Seperti Baru',
    'Baik',
    'Cukup Baik'
  ];
  final List<String> _ukuranList = [
    'XS',
    'S',
    'M',
    'L',
    'XL',
    'XXL',
    'Free Size'
  ];

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _brandController.dispose();
    _bahanController.dispose();
    _deskripsiController.dispose();
    _lokasiController.dispose();
    _kontakController.dispose();
    super.dispose();
  }

  Future<void> _pilihSumberGambar() async {
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pilih Sumber Foto',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: primaryColor),
                title: const Text('Kamera'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    final path = await _controller.ambilFotoDariKamera();
                    if (path != null && mounted) {
                      setState(() => _pathGambar = path);
                      _tampilkanSnackBar('Foto berhasil ditambahkan', isSuccess: true);
                    }
                  } catch (e) {
                    _tampilkanSnackBar('Gagal mengambil foto: $e', isError: true);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: primaryColor),
                title: const Text('Galeri'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    final path = await _controller.ambilFotoDariGaleri();
                    if (path != null && mounted) {
                      setState(() => _pathGambar = path);
                      _tampilkanSnackBar('Foto berhasil ditambahkan', isSuccess: true);
                    }
                  } catch (e) {
                    _tampilkanSnackBar('Gagal mengambil foto: $e', isError: true);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _simpanBarang() async {
    // Matikan keyboard
    FocusManager.instance.primaryFocus?.unfocus();

    if (!_formKey.currentState!.validate()) {
      _tampilkanSnackBar('Mohon lengkapi semua data wajib', isError: true);
      return;
    }

    if (_pathGambar == null) {
      _tampilkanSnackBar('Foto barang wajib diisi!', isError: true);
      return;
    }

    // Mencegah double tap
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final user = await _authController.getUserLogin();

      if (user == null || user.id == null) {
        throw Exception('User tidak ditemukan. Login ulang diperlukan.');
      }

      print('🔵 Creating product for user: ${user.id}');

      // Buat object barang baru - HARGA TANPA PREFIX "Rp"
      final barangBaru = BarangJualanModel(
        namaBarang: _namaController.text.trim(),
        harga: _hargaController.text.trim(), // Kirim angka saja tanpa "Rp"
        kategori: _kategoriDipilih,
        kondisi: _kondisiDipilih,
        ukuran: _ukuranDipilih,
        brand: _brandController.text.trim(),
        bahan: _bahanController.text.trim(),
        deskripsi: _deskripsiController.text.trim(),
        lokasi: _lokasiController.text.trim(),
        kontakPenjual: _kontakController.text.trim(),
        pathGambar: _pathGambar!,
        idPenjual: user.id!,
        tanggalUpload: DateTime.now().toIso8601String(),
      );

      print('🔵 Product data prepared:');
      print('   Name: ${barangBaru.namaBarang}');
      print('   Price: ${barangBaru.harga}');
      print('   Category: ${barangBaru.kategori}');
      print('   Brand: ${barangBaru.brand}');

      // Simpan barang (akan otomatis sync ke API jika ada token)
      print('🔵 Calling tambahBarang...');
      final berhasil = await _controller.tambahBarang(barangBaru);

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (berhasil) {
        print('✅ Product saved successfully');
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Berhasil! Barang telah ditambahkan'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 2000),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        // Navigasi ke MyItemsPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyItemsPage()),
        );
      } else {
        print('❌ Failed to save product');
        _tampilkanSnackBar('Gagal menyimpan barang. Silakan coba lagi.', isError: true);
      }
    } catch (e) {
      print('❌ Exception in _simpanBarang: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _tampilkanSnackBar('Error: ${e.toString()}', isError: true);
      }
    }
  }

  void _tampilkanSnackBar(String pesan,
      {bool isSuccess = false, bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess
                  ? Icons.check_circle
                  : (isError ? Icons.error : Icons.info),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(pesan)),
          ],
        ),
        backgroundColor:
            isSuccess ? Colors.green : (isError ? Colors.red : Colors.orange),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: textLight),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(16),
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Jual Barang',
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Upload Foto
            GestureDetector(
              onTap: _pilihSumberGambar,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _pathGambar == null ? borderColor : primaryColor,
                    width: _pathGambar == null ? 1 : 2,
                  ),
                ),
                child: _pathGambar == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 48, color: textLight),
                          SizedBox(height: 8),
                          Text(
                            'Tambah Foto Barang',
                            style: TextStyle(
                              color: textLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Wajib diisi',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    : Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_pathGambar!),
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: 18,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.close,
                                    color: Colors.white, size: 18),
                                onPressed: () =>
                                    setState(() => _pathGambar = null),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: _namaController,
              decoration: _inputDecoration('Nama Barang *'),
              validator: (v) => v!.trim().isEmpty ? 'Wajib diisi' : null,
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _hargaController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Harga (Rp) *'),
              validator: (v) {
                if (v!.trim().isEmpty) return 'Wajib diisi';
                if (int.tryParse(v.trim()) == null) return 'Harus angka';
                return null;
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _kategoriDipilih,
              decoration: _inputDecoration('Kategori *'),
              items: _kategoriList
                  .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                  .toList(),
              onChanged: (v) => setState(() => _kategoriDipilih = v!),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _brandController,
              decoration: _inputDecoration('Brand *'),
              validator: (v) => v!.trim().isEmpty ? 'Wajib diisi' : null,
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _kondisiDipilih,
              decoration: _inputDecoration('Kondisi *'),
              items: _kondisiList
                  .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                  .toList(),
              onChanged: (v) => setState(() => _kondisiDipilih = v!),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _ukuranDipilih,
              decoration: _inputDecoration('Ukuran *'),
              items: _ukuranList
                  .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                  .toList(),
              onChanged: (v) => setState(() => _ukuranDipilih = v!),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _bahanController,
              decoration: _inputDecoration('Bahan *'),
              validator: (v) => v!.trim().isEmpty ? 'Wajib diisi' : null,
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _lokasiController,
              decoration: _inputDecoration('Lokasi *'),
              validator: (v) => v!.trim().isEmpty ? 'Wajib diisi' : null,
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _kontakController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration('Nomor HP/WA *'),
              validator: (v) {
                if (v!.trim().isEmpty) return 'Wajib diisi';
                if (v.trim().length < 10) return 'Nomor tidak valid';
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _deskripsiController,
              maxLines: 4,
              decoration: _inputDecoration('Deskripsi Lengkap *'),
              validator: (v) => v!.trim().isEmpty ? 'Wajib diisi' : null,
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 30),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _simpanBarang,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  disabledBackgroundColor: primaryColor.withOpacity(0.6),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Simpan Barang',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}