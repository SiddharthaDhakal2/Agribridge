import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'cart_screen.dart';
import 'order_screen.dart';
import 'profile_screen.dart';

class ButtonNavigation extends StatefulWidget {
  final int initialIndex;

  const ButtonNavigation({super.key, this.initialIndex = 0});

  @override
  State<ButtonNavigation> createState() => _ButtonNavigationState();
}

class _ButtonNavigationState extends State<ButtonNavigation> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialIndex;
    if (initial < 0) {
      _currentIndex = 0;
      return;
    }
    if (initial > 3) {
      _currentIndex = 3;
      return;
    }
    _currentIndex = initial;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomNavTheme = theme.bottomNavigationBarTheme;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomeScreen(),
          CartScreen(
            onStartShopping: () {
              setState(() {
                _currentIndex = 0;
              });
            },
          ),
          OrderScreen(
            onStartShopping: () {
              setState(() {
                _currentIndex = 0;
              });
            },
          ),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: bottomNavTheme.selectedItemColor,
        unselectedItemColor: bottomNavTheme.unselectedItemColor,
        backgroundColor: bottomNavTheme.backgroundColor,
        selectedLabelStyle:
            bottomNavTheme.selectedLabelStyle ??
            const TextStyle(fontWeight: FontWeight.bold),

        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
