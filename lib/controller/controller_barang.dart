import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../model/barang_model.dart';

class ControllerBarang {
  final ImagePicker _picker = ImagePicker();

  // Ambil foto dari kamera
  Future<String?> ambilFotoDariKamera() async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (foto != null) {
        return await _simpanFotoLokal(foto);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Ambil foto dari galeri
  Future<String?> ambilFotoDariGaleri() async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (foto != null) {
        return await _simpanFotoLokal(foto);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Simpan foto ke storage lokal
  Future<String> _simpanFotoLokal(XFile foto) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(foto.path)}';
    final String pathBaru = path.join(appDir.path, 'foto_barang', fileName);

    // Buat folder jika belum ada
    final Directory folderFoto = Directory(path.dirname(pathBaru));
    if (!await folderFoto.exists()) {
      await folderFoto.create(recursive: true);
    }

    // Copy file ke storage app
    final File fileBaru = await File(foto.path).copy(pathBaru);
    return fileBaru.path;
  }

  // Tambah barang baru
  Future<bool> tambahBarang(BarangJualanModel barang) async {
    try {
      var box = await Hive.openBox<BarangJualanModel>('box_barang_jualan');
      await box.add(barang);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Ambil semua barang user
  Future<List<BarangJualanModel>> ambilBarangUser(String idUser) async {
    try {
      var box = await Hive.openBox<BarangJualanModel>('box_barang_jualan');
      return box.values.where((barang) => barang.idPenjual == idUser).toList();
    } catch (e) {
      return [];
    }
  }

  // Ambil semua barang (untuk ditampilkan di beranda)
  Future<List<BarangJualanModel>> ambilSemuaBarang() async {
    try {
      var box = await Hive.openBox<BarangJualanModel>('box_barang_jualan');
      return box.values.toList();
    } catch (e) {
      return [];
    }
  }

  // Update barang
  Future<bool> updateBarang(BarangJualanModel barang) async {
    try {
      await barang.save();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Hapus barang
  Future<bool> hapusBarang(BarangJualanModel barang) async {
    try {
      // Hapus foto fisik juga
      if (await File(barang.pathGambar).exists()) {
        await File(barang.pathGambar).delete();
      }
      await barang.delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}