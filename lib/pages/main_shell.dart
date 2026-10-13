import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/topup_provider.dart';
import 'home_page.dart';
import 'profil_page.dart';
import 'riwayat_page.dart';

// ======================================================
// MAIN SHELL: kerangka utama dengan BottomNavigationBar.
// Sekarang StatelessWidget: tab aktif tidak lagi disimpan di sini,
// tetapi di TopUpProvider (currentIndex).
// ======================================================
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    // context.select: widget hanya rebuild jika currentIndex berubah
    // (bukan setiap kali state lain di provider berubah).
    final currentIndex =
        context.select<TopUpProvider, int>((p) => p.currentIndex);

    // Scaffold: struktur dasar halaman yang berisi body dan navigasi bawah
    return Scaffold(
      // IndexedStack: menampilkan satu halaman sesuai index, tetapi state
      // halaman lain (misal teks Player ID di Home) tetap terjaga.
      body: IndexedStack(
        index: currentIndex,
        children: const [
          HomePage(), // halaman 1
          RiwayatPage(), // halaman 2
          ProfilPage(), // halaman 3
        ],
      ),
      // BottomNavigationBar: currentIndex bergantung pada state di provider
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.orange,
        // onTap: context.read (tanpa listen) memanggil aksi setTab pada provider
        onTap: (index) => context.read<TopUpProvider>().setTab(index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
