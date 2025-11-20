import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'view/splashScreen.dart'; // Pastikan nama file sesuai
import 'model/akun_user_model.dart'; // Kita akan buat ini di Langkah 4

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Hive (Database Lokal)
  await Hive.initFlutter();

  // 2. Registrasi Adapter (Agar Hive kenal tipe data User kita)
  Hive.registerAdapter(AkunUserModelAdapter());

  // 3. Buka Box (Tempat simpan data)
  await Hive.openBox<AkunUserModel>('box_user_preloved'); // Box Data User
  await Hive.openBox('box_session'); // Box Sesi Login

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Preloved App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE84118)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}