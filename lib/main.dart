import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp -> widget wrapper utama dari aplikasi Flutter
    return MaterialApp(
      title: 'Top Up UC PUBGM', // title, nama aplikasi yang dibuat
      theme: ThemeData(
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ), // theme, menentukan aturan visual umum aplikasi
      debugShowCheckedModeBanner: false, // menonaktifkan tulisan debug di pojok kanan atas
      home: const HomePage(), // home, menentukan halaman yang ditampilkan
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Data dummy paket top up UC PUBGM (nominal & harga)
    final List<Map<String, String>> ucPackages = [
      {'uc': '60 UC', 'bonus': '', 'price': 'Rp 15.000'},
      {'uc': '325 UC', 'bonus': '+ 25 Bonus', 'price': 'Rp 75.000'},
      {'uc': '660 UC', 'bonus': '+ 60 Bonus', 'price': 'Rp 150.000'},
      {'uc': '1800 UC', 'bonus': '+ 180 Bonus', 'price': 'Rp 400.000'},
      {'uc': '3850 UC', 'bonus': '+ 385 Bonus', 'price': 'Rp 800.000'},
      {'uc': '8100 UC', 'bonus': '+ 850 Bonus', 'price': 'Rp 1.500.000'},
    ];

    // Scaffold -> struktur dasar halaman aplikasi mobile
    return Scaffold(
      backgroundColor: Colors.white, // backgroundColor mengikuti warna tema
      body: SafeArea(
        // SafeArea -> memastikan child tidak tertutup area sistem (notch, status bar)
        child: SingleChildScrollView(
          // SingleChildScrollView -> agar seluruh konten halaman bisa di-scroll
          child: Padding(
            // Padding -> memberi ruang/jarak antara konten dengan tepi layar
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              // Column -> menyusun widget secara vertikal
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row -> menyusun icon & judul secara horizontal (header)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text -> menampilkan judul aplikasi
                        const Text(
                          'Top Up UC',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Text -> subjudul aplikasi
                        Text(
                          'PUBG Mobile',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    // Icon -> ikon notifikasi di pojok kanan atas
                    Icon(
                      Icons.notifications_none,
                      size: 28,
                      color: Colors.grey.shade700,
                    ),
                  ],
                ),

                // SizedBox -> memberi jarak vertikal antar bagian
                const SizedBox(height: 20),

                // Container -> membungkus form input ID akun menjadi sebuah card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    border: Border.all(color: Colors.orange.shade100),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text -> label form input
                      const Text(
                        'Masukkan ID Akun',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      // TextField -> input untuk ID akun pemain
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Contoh: 5123456789',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          // Icon di dalam TextField sebagai suffixIcon
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(
                              Icons.person_outline,
                              size: 22,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // TextField -> input untuk Zone ID / Server ID
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Zone ID (opsional)',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(
                              Icons.search,
                              size: 22,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Text -> judul bagian daftar paket UC
                const Text(
                  'Pilih Nominal UC',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Column berisi daftar Container (card) paket UC, digenerate dari list data
                Column(
                  children: ucPackages.map((item) {
                    return Padding(
                      // Padding -> jarak antar card paket
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        // Container -> membungkus setiap paket UC menjadi card
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          // Row -> menyusun icon, info paket, dan harga secara horizontal
                          children: [
                            // Icon -> representasi item UC (mata uang game)
                            Icon(
                              Icons.diamond_outlined,
                              size: 28,
                              color: Colors.orange.shade400,
                            ),
                            const SizedBox(width: 12), // jarak antara icon dan teks
                            Expanded(
                              // Expanded -> agar kolom info mengisi sisa ruang pada Row
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Text -> jumlah UC pada paket
                                  Text(
                                    item['uc']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (item['bonus']!.isNotEmpty)
                                    // Text -> keterangan bonus UC (jika ada)
                                    Text(
                                      item['bonus']!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green.shade600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Text -> menampilkan harga paket
                            Text(
                              item['price']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}