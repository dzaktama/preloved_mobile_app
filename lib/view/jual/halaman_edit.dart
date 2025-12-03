// Path: lib/view/jual/halaman_edit_barang.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../controller/controller_barang.dart';
import '../../model/barang_model.dart';

class HalamanEditBarang extends StatefulWidget {
  final BarangJualanModel barang;

  const HalamanEditBarang({super.key, required this.barang});

  @override
  State<HalamanEditBarang> createState() => _HalamanEditBarangState();
}

class _HalamanEditBarangState extends State<HalamanEditBarang> {
  final _formKey = GlobalKey<FormState>();
  final ControllerBarang _controller = ControllerBarang();

  late TextEditingController _namaController;
  late TextEditingController _hargaController;
  late TextEditingController _brandController;
  late TextEditingController _bahanController;
  late TextEditingController _deskripsiController;
  late TextEditingController _lokasiController;
  late TextEditingController _kontakController;

  String? _pathGambar;
  String? _gambarUrl;
  late String _kategoriDipilih;
  late String _kondisiDipilih;
  late String _ukuranDipilih;

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
  void initState() {
    super.initState();
    
    // Initialize controllers dengan data barang yang ada
    _namaController = TextEditingController(text: widget.barang.namaBarang);
    _hargaController = TextEditingController(
      text: widget.barang.harga.replaceAll(RegExp(r'[^0-9]'), ''),
    );
    _brandController = TextEditingController(text: widget.barang.brand);
    _bahanController = TextEditingController(text: widget.barang.bahan);
    _deskripsiController = TextEditingController(text: widget.barang.deskripsi);
    _lokasiController = TextEditingController(text: widget.barang.lokasi);
    _kontakController = TextEditingController(text: widget.barang.kontakPenjual);

    _pathGambar = widget.barang.pathGambar;
    _gambarUrl = widget.barang.gambarUrl;
    _kategoriDipilih = widget.barang.kategori;
    _kondisiDipilih = widget.barang.kondisi;
    _ukuranDipilih = widget.barang.ukuran;
  }

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
                'Ubah Foto Barang',
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
                      setState(() {
                        _pathGambar = path;
                        _gambarUrl = null; // Clear URL karena ada foto baru
                      });
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
                  Navigator.pop(context);
                  try {
                    final path = await _controller.ambilFotoDariGaleri();
                    if (path != null && mounted) {
                      setState(() {
                        _pathGambar = path;
                        _gambarUrl = null; // Clear URL karena ada foto baru
                      });
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

  Future<void> _updateBarang() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!_formKey.currentState!.validate()) {
      _tampilkanSnackBar('Mohon lengkapi semua data wajib', isError: true);
      return;
    }

    if (_pathGambar == null && _gambarUrl == null) {
      _tampilkanSnackBar('Foto barang wajib ada!', isError: true);
      return;
    }

    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final barangUpdate = widget.barang.copy(
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
        pathGambar: _pathGambar ?? '',
        gambarUrl: _gambarUrl,
      );

      final berhasil = await _controller.updateBarang(barangUpdate);

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (berhasil) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Barang berhasil diupdate!'),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 1500),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        // Kembali dengan hasil success
        Navigator.pop(context, true);
      } else {
        _tampilkanSnackBar('Gagal mengupdate barang', isError: true);
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

  Widget _buildImageDisplay() {
    // Prioritas: pathGambar lokal > gambarUrl dari API
    if (_pathGambar != null && _pathGambar!.isNotEmpty) {
      // Gambar lokal
      return Stack(
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
                icon: const Icon(Icons.close, color: Colors.white, size: 16),
                onPressed: () => setState(() {
                  _pathGambar = null;
                }),
              ),
            ),
          ),
        ],
      );
    } else if (_gambarUrl != null && _gambarUrl!.isNotEmpty) {
      // Gambar dari URL (API)
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              _gambarUrl!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.broken_image, size: 48, color: textLight),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
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
                icon: const Icon(Icons.close, color: Colors.white, size: 16),
                onPressed: () => setState(() {
                  _gambarUrl = null;
                }),
              ),
            ),
          ),
        ],
      );
    } else {
      // Tidak ada gambar
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo, size: 48, color: textLight),
          SizedBox(height: 8),
          Text(
            'Tambah Foto Barang',
            style: TextStyle(color: textLight, fontWeight: FontWeight.bold),
          ),
        ],
      );
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
          'Edit Barang',
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Upload/Edit Foto
            GestureDetector(
              onTap: _pilihSumberGambar,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: _buildImageDisplay(),
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
                onPressed: _isLoading ? null : _updateBarang,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Update Barang',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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