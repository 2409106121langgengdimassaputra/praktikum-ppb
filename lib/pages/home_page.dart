import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // untuk membatasi input TextField hanya angka
import 'package:provider/provider.dart';
import '../models/paket_uc.dart';
import '../providers/topup_provider.dart';
import '../utils/format.dart';
import 'confirm_page.dart';

// ======================================================
// HALAMAN 1: HOME PAGE
// State lokal (setState): hanya _idController (objek controller TextField).
// State bersama (Provider): idText, searchQuery, selectedPaket, dan derived state
// idValid, bisaLanjut, paketTampil -> semuanya ada di TopUpProvider.
// ======================================================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _idController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  // Fungsi pembuat kartu paket UC (dipakai berulang)
  Widget _kartuPaket(TopUpProvider topup, PaketUc paket) {
    final selected = topup.selectedPaket?.nama == paket.nama;
    // GestureDetector: mendeteksi ketukan pada kartu paket
    return GestureDetector(
      // context.read: memanggil aksi pilihPaket di provider (tanpa mendengarkan)
      onTap: () => context.read<TopUpProvider>().pilihPaket(paket),
      // Container: membungkus isi paket menjadi bentuk card
      child: Container(
        padding: const EdgeInsets.all(12),
        // BoxDecoration: warna, border (berubah sesuai state selected), kelengkungan
        decoration: BoxDecoration(
          color: selected ? Colors.orange.shade50 : Colors.white,
          border: Border.all(
            color: selected ? Colors.orange : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        // Column: menyusun isi card secara vertikal
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Row: ikon dan jumlah UC sejajar horizontal
            Row(
              children: [
                const Icon(Icons.monetization_on, size: 20, color: Colors.orange), // Icon
                const SizedBox(width: 6), // SizedBox
                Text(paket.nama,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // Text
              ],
            ),
            const SizedBox(height: 4),
            Text(formatRupiah(paket.harga),
                style: TextStyle(color: Colors.grey.shade600)), // Text
          ],
        ),
      ),
    );
  }

  // Pindah ke halaman konfirmasi
  void _lanjutKonfirmasi() {
    final topup = context.read<TopUpProvider>();
    topup.simpanPlayerId(); // simpan Player ID di provider (untuk ProfilPage)
    // Navigator.push: membuka ConfirmPage dan menambahkannya ke navigation stack
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmPage(
          playerId: topup.idText,
          paket: topup.selectedPaket!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Consumer: mendengarkan TopUpProvider; builder dipanggil ulang saat notifyListeners()
    return Consumer<TopUpProvider>(
      builder: (context, topup, child) {
        // Derived state: daftar paket yang tampil, difilter di provider
        final visiblePaket = topup.paketTampil;
        final selectedPaket = topup.selectedPaket;

    // Scaffold: struktur dasar halaman
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      // SafeArea: memastikan konten tidak tertutup area sistem perangkat
      body: SafeArea(
        // SingleChildScrollView: agar halaman bisa di-scroll
        child: SingleChildScrollView(
          // Padding: memberi ruang di sekeliling konten
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            // Column: menyusun seluruh bagian halaman secara vertikal
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== HEADER =====
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Halo, Survivor!',
                            style: TextStyle(color: Colors.grey.shade600)), // Text
                        const Text('TopUp UC PUBGM',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), // Text
                      ],
                    ),
                    const Icon(Icons.notifications, size: 28), // Icon
                  ],
                ),

                const SizedBox(height: 20),

                // ===== BANNER PROMO (Stack + Positioned + Image) =====
                // Stack: menumpuk gambar banner, lapisan gelap, dan teks promo
                SizedBox(
                  height: 160,
                  child: Stack(
                    children: [
                      // Positioned: gambar banner memenuhi seluruh area Stack
                      Positioned.fill(
                        // Image.asset: gambar banner dari folder assets
                        child: Image.asset(
                          'assets/images/banner_pubg.png',
                          fit: BoxFit.cover,
                          // errorBuilder: tampilan cadangan jika aset belum ditambahkan
                          errorBuilder: (context, error, stackTrace) => Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ),
                      // Positioned: lapisan gelap tipis agar teks terbaca
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.black.withValues(alpha: 0.25),
                          ),
                        ),
                      ),
                      // Positioned: teks promo di kiri bawah
                      const Positioned(
                        left: 16,
                        bottom: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Promo Spesial!',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)), // Text
                            SizedBox(height: 4),
                            Text('Bonus UC untuk top up pertama kamu',
                                style: TextStyle(color: Colors.white)), // Text
                          ],
                        ),
                      ),
                      // Positioned: ikon api di kanan atas
                      const Positioned(
                        right: 16,
                        top: 16,
                        child: Icon(Icons.local_fire_department,
                            size: 40, color: Colors.white), // Icon
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ===== INPUT PLAYER ID =====
                const Text('Player ID',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // Text
                const SizedBox(height: 8),
                // TextField: onChanged mengirim teks ke provider (setIdText) setiap user mengetik
                TextField(
                  controller: _idController,
                  keyboardType: TextInputType.number,
                  // inputFormatters: hanya digit, maksimal 12 karakter
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(12),
                  ],
                  onChanged: (value) => context.read<TopUpProvider>().setIdText(value),
                  decoration: InputDecoration(
                    hintText: 'Masukkan Player ID PUBGM (8-12 angka)',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: Colors.white,
                    // errorText: muncul otomatis dari derived state idValid (di provider)
                    errorText: topup.idText.isNotEmpty && !topup.idValid
                        ? 'Player ID harus 8-12 digit'
                        : null,
                    // suffixIcon: ikon berubah menjadi centang jika ID valid
                    suffixIcon: Icon(
                      topup.idValid ? Icons.check_circle : Icons.person,
                      color: topup.idValid ? Colors.green : Colors.grey.shade400,
                    ), // Icon
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),

                const SizedBox(height: 20),

                // ===== KEUNGGULAN =====
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Expanded: tiap keunggulan mendapat lebar yang sama
                    Expanded(
                      child: Column(
                        children: [
                          Icon(Icons.flash_on, color: Colors.orange), // Icon
                          SizedBox(height: 4),
                          Text('Instan'), // Text
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Icon(Icons.security, color: Colors.orange), // Icon
                          SizedBox(height: 4),
                          Text('Aman'), // Text
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Icon(Icons.support_agent, color: Colors.orange), // Icon
                          SizedBox(height: 4),
                          Text('Bantuan 24 Jam'), // Text
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ===== PILIH NOMINAL UC + PENCARIAN =====
                const Text('Pilih Nominal UC',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // Text
                const SizedBox(height: 12),
                // TextField pencarian: onChanged mengubah searchQuery di provider
                TextField(
                  onChanged: (value) =>
                      context.read<TopUpProvider>().setSearchQuery(value),
                  decoration: InputDecoration(
                    hintText: 'Cari paket, contoh: 660',
                    prefixIcon: const Icon(Icons.search), // Icon
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                // Jika hasil filter kosong tampilkan pesan, jika ada tampilkan grid paket
                if (visiblePaket.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text('Paket tidak ditemukan',
                          style: TextStyle(color: Colors.grey.shade600)), // Text
                    ),
                  )
                else
                  // GridView.count: menampilkan paket 2 kolom; shrinkWrap + NeverScrollable
                  // karena sudah berada di dalam SingleChildScrollView
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.2,
                    children: visiblePaket.map((p) => _kartuPaket(topup, p)).toList(),
                  ),

                const SizedBox(height: 16),

                // ===== RINGKASAN PILIHAN (muncul hanya jika ada paket terpilih) =====
                if (selectedPaket != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Dipilih: ${selectedPaket.nama} - ${formatRupiah(selectedPaket.harga)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ), // Text
                  ),

                const SizedBox(height: 16),

                // ===== TOMBOL LANJUT =====
                // SizedBox: membuat tombol selebar layar
                SizedBox(
                  width: double.infinity,
                  // ElevatedButton: onPressed null = tombol nonaktif (derived state bisaLanjut)
                  child: ElevatedButton.icon(
                    onPressed: topup.bisaLanjut ? _lanjutKonfirmasi : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.shopping_cart), // Icon
                    label: const Text('Lanjut Top Up',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // Text
                  ),
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
}
