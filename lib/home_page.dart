import 'package:flutter/material.dart';
import 'kegiatan_page.dart';
import 'jadwal_page.dart';
import 'profil.dart';
import 'tugas_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

final List<Widget> _pages = const [
  KegiatanPage(),
  JadwalPage(),
  TugasPage(), // ← tambah ini
  ProfilPage(),
];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
          icon: Icon(Icons.task),
          label: 'Tugas',
      ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Belajar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
