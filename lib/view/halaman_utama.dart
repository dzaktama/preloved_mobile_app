import 'package:flutter/material.dart';
// nanti import halaman tab lainnya disini (beranda, jual, profil)

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  int _currentIndex = 0;

  // sementara pake placeholder dulu biar ga error
  final List<Widget> _pages = [
    const Center(child: Text("Halaman Beranda")), // Nanti ganti HalamanBeranda()
    const Center(child: Text("Halaman Jual")),    // Nanti ganti HalamanTambah()
    const Center(child: Text("Halaman Profil")),  // Nanti ganti HalamanProfil()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFFE84118), // Warna oranye khas
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Jual',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}