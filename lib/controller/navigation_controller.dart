import 'package:flutter/material.dart';

class NavigationController extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void changeTab(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void goToHome() {
    _currentIndex = 0;
    notifyListeners();
  }

  void goToSearch() {
    _currentIndex = 1;
    notifyListeners();
  }

  void goToSell() {
    _currentIndex = 2;
    notifyListeners();
  }

  void goToInbox() {
    _currentIndex = 3;
    notifyListeners();
  }

  void goToProfile() {
    _currentIndex = 4;
    notifyListeners();
  }
}