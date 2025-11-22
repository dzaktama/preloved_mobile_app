import 'package:hive_flutter/hive_flutter.dart';
import '../model/address_model.dart';

class AddressController {
  // Tambah alamat baru
  Future<bool> tambahAlamat(AddressModel alamat) async {
    try {
      var box = await Hive.openBox<AddressModel>('box_address');
      
      // Generate ID
      alamat.idAddress = alamat.generateId();
      
      // Jika ini alamat pertama atau set sebagai primary, update alamat lain
      if (alamat.isPrimary == true) {
        await _setPrimaryAddress(alamat.idUser!, alamat.idAddress!);
      }
      
      await box.add(alamat);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Ambil semua alamat user
  Future<List<AddressModel>> ambilAlamatUser(String idUser) async {
    try {
      var box = await Hive.openBox<AddressModel>('box_address');
      return box.values
          .where((alamat) => alamat.idUser == idUser)
          .toList()
        ..sort((a, b) {
          // Primary address di atas
          if (a.isPrimary == true && b.isPrimary != true) return -1;
          if (b.isPrimary == true && a.isPrimary != true) return 1;
          return 0;
        });
    } catch (e) {
      return [];
    }
  }

  // Ambil primary address
  Future<AddressModel?> ambilPrimaryAddress(String idUser) async {
    try {
      var box = await Hive.openBox<AddressModel>('box_address');
      return box.values.firstWhere(
        (alamat) => alamat.idUser == idUser && alamat.isPrimary == true,
      );
    } catch (e) {
      return null;
    }
  }

  // Set alamat sebagai primary
  Future<bool> setPrimaryAddress(String idUser, String idAddress) async {
    try {
      await _setPrimaryAddress(idUser, idAddress);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _setPrimaryAddress(String idUser, String idAddress) async {
    var box = await Hive.openBox<AddressModel>('box_address');
    
    // Set semua alamat user jadi false
    for (var alamat in box.values) {
      if (alamat.idUser == idUser && alamat.isPrimary == true) {
        alamat.isPrimary = false;
        await alamat.save();
      }
    }
    
    // Set alamat yang dipilih jadi true
    for (var alamat in box.values) {
      if (alamat.idAddress == idAddress) {
        alamat.isPrimary = true;
        await alamat.save();
        break;
      }
    }
  }

  // Update alamat
  Future<bool> updateAlamat(AddressModel alamat) async {
    try {
      // Jika diset sebagai primary
      if (alamat.isPrimary == true) {
        await _setPrimaryAddress(alamat.idUser!, alamat.idAddress!);
      }
      
      await alamat.save();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Hapus alamat
  Future<bool> hapusAlamat(AddressModel alamat) async {
    try {
      // Cek apakah ini primary address
      bool wasPrimary = alamat.isPrimary == true;
      String userId = alamat.idUser!;
      
      await alamat.delete();
      
      // Jika yang dihapus primary, set alamat pertama sebagai primary
      if (wasPrimary) {
        var addresses = await ambilAlamatUser(userId);
        if (addresses.isNotEmpty) {
          addresses.first.isPrimary = true;
          await addresses.first.save();
        }
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
}