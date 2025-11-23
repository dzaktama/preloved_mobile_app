import 'package:flutter/material.dart';
import '../controller/navigation_controller.dart';
import 'halaman_utama.dart';
import 'my_items_page.dart';
import '../view/jual/halaman_tambah.dart';
import 'inbox_page.dart';
import '../view/profil/profile.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  final NavigationController _navController = NavigationController();

  static const Color primaryColor = Color(0xFFE84118);
  static const Color textDark = Color(0xFF2F3640);
  static const Color textLight = Color(0xFF57606F);
  static const Color backgroundColor = Color(0xFFFAFAFA);

  final List<Widget> _pages = [
    const HomePage(),
    const MyItemsPage(),
    const HalamanTambahBarang(),
    const InboxPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _navController,
      builder: (context, child) {
        return Scaffold(
          body: IndexedStack(
            index: _navController.currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home,
                      label: 'Home',
                      index: 0,
                    ),
                    _buildNavItem(
                      icon: Icons.inventory_2_outlined,
                      activeIcon: Icons.inventory_2,
                      label: 'My Items',
                      index: 1,
                    ),
                    _buildNavItem(
                      icon: Icons.add_circle_outline,
                      activeIcon: Icons.add_circle,
                      label: 'Jual',
                      index: 2,
                      isCenter: true,
                    ),
                    _buildNavItem(
                      icon: Icons.inbox_outlined,
                      activeIcon: Icons.inbox,
                      label: 'Inbox',
                      index: 3,
                    ),
                    _buildNavItem(
                      icon: Icons.person_outline,
                      activeIcon: Icons.person,
                      label: 'Profil',
                      index: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    bool isCenter = false,
  }) {
    final isActive = _navController.currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _navController.changeTab(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: isActive ? primaryColor : textLight,
                size: isCenter ? 28 : 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? primaryColor : textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _navController.dispose();
    super.dispose();
  }
}