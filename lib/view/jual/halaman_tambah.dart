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
    // Tutup keyboard jika terbuka
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
                  Navigator.pop(context); // Tutup bottom sheet
                  try {
                    final path = await _controller.ambilFotoDariKamera();
                    if (path != null && mounted) {
                      setState(() => _pathGambar = path);
                    }
                  } catch (e) {
                    // ignore error
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: primaryColor),
                title: const Text('Galeri'),
                onTap: () async {
                  Navigator.pop(context); // Tutup bottom sheet
                  try {
                    final path = await _controller.ambilFotoDariGaleri();
                    if (path != null && mounted) {
                      setState(() => _pathGambar = path);
                    }
                  } catch (e) {
                    // ignore error
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
    // 1. Matikan Keyboard (PENTING: Mencegah UI glitch/black screen)
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

      final barangBaru = BarangJualanModel(
        namaBarang: _namaController.text.trim(),
        harga: 'Rp ${_hargaController.text.trim()}',
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

      final berhasil = await _controller.tambahBarang(barangBaru);

      if (!mounted) return;

      // 2. MATIKAN LOADING SEBELUM PINDAH HALAMAN
      setState(() => _isLoading = false);

      if (berhasil) {
        // Tampilkan notifikasi sukses sebentar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil! Mengalihkan ke Item Saya...'),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 1000),
          ),
        );

        // Tunggu sebentar biar UX lebih halus
        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        // 3. NAVIGASI YANG BENAR: Ganti halaman ini dengan MyItemsPage
        // Ini akan membuang halaman "Tambah Barang" dari stack, jadi tidak bisa kembali ke sini (bagus untuk form)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyItemsPage()),
        );
      } else {
        _tampilkanSnackBar('Gagal menyimpan barang', isError: true);
      }
    } catch (e) {
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
        duration: const Duration(seconds: 2),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      // AppBar
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
      // Body
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
                  border: Border.all(color: borderColor),
                ),
                child: _pathGambar == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 48, color: textLight),
                          SizedBox(height: 8),
                          Text('Tambah Foto Barang',
                              style: TextStyle(
                                  color: textLight,
                                  fontWeight: FontWeight.bold)),
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
                              radius: 16,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.close,
                                    color: Colors.white, size: 16),
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
              decoration: _inputDecoration('Nama Barang'),
              validator: (v) => v!.trim().isEmpty ? 'Wajib diisi' : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _hargaController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Harga (Angka saja)'),
              validator: (v) => v!.trim().isEmpty ? 'Wajib diisi' : null,
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _kategoriDipilih,
              decoration: _inputDecoration('Kategori'),
              items: _kategoriList
                  .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                  .toList(),
              onChanged: (v) => setState(() => _kategoriDipilih = v!),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _brandController,
              decoration: _inputDecoration('Brand'),
              validator: (v) => v!.trim().isEmpty ? 'Wajib diisi' : null,
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _kondisiDipilih,
              decoration: _inputDecoration('Kondisi'),
              items: _kondisiList
                  .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                  .toList(),
              onChanged: (v) => setState(() => _kondisiDipilih = v!),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _ukuranDipilih,
              decoration: _inputDecoration('Ukuran'),
              items: _ukuranList
                  .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                  .toList(),
              onChanged: (v) => setState(() => _ukuranDipilih = v!),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _bahanController,
              decoration: _inputDecoration('Bahan'),
              validator: (v) => v!.trim().isEmpty ? 'Wajib diisi' : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _lokasiController,
              decoration: _inputDecoration('Lokasi'),
              validator: (v) => v!.trim().isEmpty ? 'Wajib diisi' : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _kontakController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration('Nomor HP/WA'),
              validator: (v) => v!.trim().isEmpty ? 'Wajib diisi' : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _deskripsiController,
              maxLines: 4,
              decoration: _inputDecoration('Deskripsi Lengkap'),
              validator: (v) => v!.trim().isEmpty ? 'Wajib diisi' : null,
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
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
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
