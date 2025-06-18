import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

import '../Beranda/beranda.dart';
import '../SetorSampah/pilih_bank_sampah.dart';
import '../Artikel/artikel.dart';
import '../TukarPoin/tukar_poin.dart';
import '../Profil/profil.dart';

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final navigationKey = GlobalKey<CurvedNavigationBarState>();
  int _currentIndex = 0;

  static _MenuState? of(BuildContext context) {
    final state = context.findAncestorStateOfType<_MenuState>();
    return state;
  }

  void changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<Widget> _screens = [
    Beranda(),
    PilihBankSampah(),
    Artikel(),
    TukarPoin(),
    Profil(),
  ];

  final List<IconData> _icons = [
    Icons.home_rounded,
    Icons.recycling_rounded,
    Icons.search_rounded,
    Icons.stars_rounded,
    Icons.account_circle_rounded,
  ];

  final List<String> _labels = [
    "Beranda",
    "Setor Sampah",
    "Edukasi",
    "Poin",
    "Profil",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        key: navigationKey,
        index: _currentIndex,
        items: List.generate(_icons.length, (i) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _icons[i],
              size: 30,
              color: _currentIndex == i ? Colors.white : Color(0xFF3D8D7A),
            ),
            if (_currentIndex != i)
              Text(
                _labels[i],
                style: TextStyle(fontSize: 12, color: Color(0xFF3D8D7A)),
              ),
          ],
        )),
        height: 65,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Color(0xFF3D8D7A),
      ),
    );
  }
}