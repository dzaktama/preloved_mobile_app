import 'dart:io';
import 'package:flutter/material.dart';
import '../../controller/controller_barang.dart';
import '../../controller/helper_gambar.dart';
import '../../model/barang_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HalamanTambahBarang extends StatefulWidget {
  const HalamanTambahBarang({Key? key}) : super(key: key);

  @override
  State<HalamanTambahBarang> createState() => _HalamanTambahBarangState();
}

class _HalamanTambahBarangState extends State<HalamanTambahBarang> {
  final _formKey = GlobalKey<FormState>();
  final ControllerBarang _controller = ControllerBarang();

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

  final List<String> _kategoriList = ['Pakaian', 'Sepatu', 'Aksesoris', 'Tas', 'Jam Tangan', 'Lainnya'];
  final List<String> _kondisiList = ['Baru', 'Seperti Baru', 'Baik', 'Cukup Baik'];
  final List<String> _ukuranList = ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'Free Size'];

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
                  if (path != null) {
                    setState(() => _pathGambar = path);
                  }
                } catch (e) {
                  if (mounted) {
                    _tampilkanSnackBar('Gagal mengambil foto dari kamera');
                  }
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
                  if (path != null) {
                    setState(() => _pathGambar = path);
                  }
                } catch (e) {
                  if (mounted) {
                    _tampilkanSnackBar('Gagal mengambil foto dari galeri');
                  }
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
    if (!_formKey.currentState!.validate()) return;

    if (_pathGambar == null) {
      _tampilkanSnackBar('Foto barang wajib diisi!');
      return;
    }

    setState(() => _isLoading = true);

    // Ambil ID user yang sedang login
    var sessionBox = await Hive.openBox('box_session');
    String idUser = sessionBox.get('id_user', defaultValue: 'unknown').toString();

    final barangBaru = BarangJualanModel(
      namaBarang: _namaController.text,
      harga: 'Rp ${_hargaController.text}',
      kategori: _kategoriDipilih,
      kondisi: _kondisiDipilih,
      ukuran: _ukuranDipilih,
      brand: _brandController.text,
      bahan: _bahanController.text,
      deskripsi: _deskripsiController.text,
      lokasi: _lokasiController.text,
      kontakPenjual: _kontakController.text,
      pathGambar: _pathGambar!,
      idPenjual: idUser,
      tanggalUpload: DateTime.now(),
    );

    final berhasil = await _controller.tambahBarang(barangBaru);

    setState(() => _isLoading = false);

    if (berhasil) {
      _tampilkanSnackBar('Barang berhasil ditambahkan!', isSuccess: true);
      Navigator.pop(context, true);
    } else {
      _tampilkanSnackBar('Gagal menambahkan barang');
    }
  }

  void _tampilkanSnackBar(String pesan, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
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
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Upload foto
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
                          Text(
                            'Tambah Foto Barang',
                            style: TextStyle(color: textLight),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_pathGambar!),
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // Nama barang
            TextFormField(
              controller: _namaController,
              decoration: _inputDecoration('Nama Barang'),
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),

            const SizedBox(height: 16),

            // Harga
            TextFormField(
              controller: _hargaController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Harga (tanpa Rp)'),
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),

            const SizedBox(height: 16),

            // Kategori
            DropdownButtonFormField<String>(
              value: _kategoriDipilih,
              decoration: _inputDecoration('Kategori'),
              items: _kategoriList.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
              onChanged: (v) => setState(() => _kategoriDipilih = v!),
            ),

            const SizedBox(height: 16),

            // Brand
            TextFormField(
              controller: _brandController,
              decoration: _inputDecoration('Brand'),
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),

            const SizedBox(height: 16),

            // Kondisi
            DropdownButtonFormField<String>(
              value: _kondisiDipilih,
              decoration: _inputDecoration('Kondisi'),
              items: _kondisiList.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
              onChanged: (v) => setState(() => _kondisiDipilih = v!),
            ),

            const SizedBox(height: 16),

            // Ukuran
            DropdownButtonFormField<String>(
              value: _ukuranDipilih,
              decoration: _inputDecoration('Ukuran'),
              items: _ukuranList.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
              onChanged: (v) => setState(() => _ukuranDipilih = v!),
            ),

            const SizedBox(height: 16),

            // Bahan
            TextFormField(
              controller: _bahanController,
              decoration: _inputDecoration('Bahan'),
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),

            const SizedBox(height: 16),

            // Lokasi
            TextFormField(
              controller: _lokasiController,
              decoration: _inputDecoration('Lokasi (Kota)'),
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),

            const SizedBox(height: 16),

            // Kontak
            TextFormField(
              controller: _kontakController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration('Nomor Kontak'),
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),

            const SizedBox(height: 16),

            // Deskripsi
            TextFormField(
              controller: _deskripsiController,
              maxLines: 4,
              decoration: _inputDecoration('Deskripsi'),
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),

            const SizedBox(height: 24),

            // Tombol simpan
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _simpanBarang,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Simpan Barang',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
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
}