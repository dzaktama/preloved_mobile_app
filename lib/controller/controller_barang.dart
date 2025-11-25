import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../model/barang_model.dart';
import '../services/database_helper.dart';

class ControllerBarang {
  final ImagePicker _picker = ImagePicker();
  final dbHelper = DatabaseHelper.instance;

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
      print('Error ambilFotoDariKamera: $e');
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
      print('Error ambilFotoDariGaleri: $e');
      return null;
    }
  }

  // Simpan foto ke storage lokal
  Future<String> _simpanFotoLokal(XFile foto) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String fileName =
        '${DateTime.now().millisecondsSinceEpoch}${path.extension(foto.path)}';
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
      final db = await dbHelper.database;
      await db.insert('barang_jualan', barang.toMap());
      return true;
    } catch (e) {
      print('Error tambahBarang: $e');
      return false;
    }
  }

  // Ambil semua barang user
  Future<List<BarangJualanModel>> ambilBarangUser(int userId) async {
    try {
      final db = await dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'barang_jualan',
        where: 'id_penjual = ?',
        whereArgs: [userId],
        orderBy: 'tanggal_upload DESC',
      );

      return List.generate(maps.length, (i) {
        return BarangJualanModel.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error ambilBarangUser: $e');
      return [];
    }
  }

  // Ambil semua barang (untuk ditampilkan di beranda)
  Future<List<BarangJualanModel>> ambilSemuaBarang() async {
    try {
      final db = await dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'barang_jualan',
        orderBy: 'tanggal_upload DESC',
      );

      return List.generate(maps.length, (i) {
        return BarangJualanModel.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error ambilSemuaBarang: $e');
      return [];
    }
  }

  // Update barang
  Future<bool> updateBarang(BarangJualanModel barang) async {
    try {
      final db = await dbHelper.database;

      await db.update(
        'barang_jualan',
        barang.toMap(),
        where: 'id = ?',
        whereArgs: [barang.id],
      );

      return true;
    } catch (e) {
      print('Error updateBarang: $e');
      return false;
    }
  }

  // Hapus barang
  Future<bool> hapusBarang(BarangJualanModel barang) async {
    try {
      final db = await dbHelper.database;

      // Hapus foto fisik juga
      if (await File(barang.pathGambar).exists()) {
        await File(barang.pathGambar).delete();
      }

      await db.delete(
        'barang_jualan',
        where: 'id = ?',
        whereArgs: [barang.id],
      );

      return true;
    } catch (e) {
      print('Error hapusBarang: $e');
      return false;
    }
  }
}