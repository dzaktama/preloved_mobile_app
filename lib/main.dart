import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'view/splashScreen.dart';
import 'model/userModel.dart';
import 'model/transaksi_model.dart';
import 'model/cart_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(TransaksiModelAdapter());
  Hive.registerAdapter(ItemTransaksiAdapter());
  Hive.registerAdapter(CartModelAdapter());

  await Hive.openBox<UserModel>('box_user_preloved');
  await Hive.openBox('box_session');
  await Hive.openBox<TransaksiModel>('box_transaksi');
  await Hive.openBox<CartModel>('box_cart');

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
