import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // untuk membatasi input TextField hanya angka
import 'app_state.dart'; // file terpisah untuk menyimpan player ID & riwayat transaksi

// Fungsi utama: titik awal aplikasi Flutter
void main() {
  runApp(const TopUpApp());
}

class TopUpApp extends StatelessWidget {
  const TopUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp: widget wrapper utama aplikasi
    return MaterialApp(
      title: 'TopUp UC PUBGM',
      debugShowCheckedModeBanner: false, // menonaktifkan banner debug
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      home: const HomePage(), // halaman pertama yang ditampilkan
    );
  }
}

// ======================================================
// HALAMAN 1: HOME PAGE
// ======================================================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _idController = TextEditingController();
  String _selectedUc = '';
  int _selectedPrice = 0;

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  // Fungsi pembuat kartu paket UC (dipakai berulang)
  Widget _paketUc(String uc, int harga) {
    final selected = _selectedUc == uc;
    // GestureDetector: mendeteksi ketukan pada kartu paket
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedUc = uc;
          _selectedPrice = harga;
        });
      },
      // Container: membungkus isi paket menjadi bentuk card
      child: Container(
        padding: const EdgeInsets.all(12),
        // BoxDecoration: warna, border, dan kelengkungan card
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: selected ? Colors.orange : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        // Column: menyusun isi card secara vertikal
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row: ikon dan jumlah UC sejajar horizontal
            Row(
              children: [
                const Icon(Icons.monetization_on, size: 20, color: Colors.orange), // Icon
                const SizedBox(width: 6), // SizedBox
                Text(uc, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // Text
              ],
            ),
            const SizedBox(height: 4),
            Text('Rp$harga', style: TextStyle(color: Colors.grey.shade600)), // Text
          ],
        ),
      ),
    );
  }

  Widget _barisPaket(String uc1, int h1, String uc2, int h2) {
    // Row: dua paket dalam satu baris
    return Row(
      children: [
        Expanded(child: _paketUc(uc1, h1)), // Expanded
        const SizedBox(width: 12), // SizedBox
        Expanded(child: _paketUc(uc2, h2)), // Expanded
      ],
    );
  }

  // Fungsi ketika tombol Top Up ditekan -> pindah ke halaman konfirmasi
  void _lanjutKonfirmasi() {
    if (_idController.text.isEmpty || _selectedUc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Isi Player ID dan pilih paket UC terlebih dahulu'),
      ));
      return;
    }
    // Menyimpan Player ID yang diinput user ke AppState agar bisa dipakai di ProfilPage
    AppState.playerId = _idController.text;
    // Navigator.push: membuka halaman baru (ConfirmPage) dan menambahkannya ke navigation stack
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmPage(
          playerId: _idController.text,
          uc: _selectedUc,
          harga: _selectedPrice,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                        Text('Halo, Survivor!', style: TextStyle(color: Colors.grey.shade600)), // Text
                        const Text('TopUp UC PUBGM',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), // Text
                      ],
                    ),
                    const Icon(Icons.notifications, size: 28), // Icon
                  ],
                ),

                const SizedBox(height: 20),

                // ===== BANNER PROMO (pakai Stack + Positioned + Image) =====
                // Stack: menumpuk gambar banner, lapisan gelap, dan teks promo
                SizedBox(
                  height: 160,
                  child: Stack(
                    children: [
                      // Positioned: gambar banner memenuhi seluruh area Stack
                      Positioned.fill(
                        // Image.asset: menampilkan gambar banner dari folder assets
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
                      // Positioned: lapisan gelap tipis di atas gambar agar teks terbaca
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.black.withValues(alpha: 0.25),
                          ),
                        ),
                      ),
                      // Positioned: teks promo diletakkan di kiri bawah Stack
                      Positioned(
                        left: 16,
                        bottom: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Promo Spesial!',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            SizedBox(height: 4),
                            Text('Bonus UC untuk top up pertama kamu',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      // Positioned: ikon api di kanan atas Stack
                      const Positioned(
                        right: 16,
                        top: 16,
                        child: Icon(Icons.local_fire_department, size: 40, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ===== INPUT PLAYER ID =====
                const Text('Player ID', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                // TextField: input Player ID, dibatasi hanya boleh angka
                TextField(
                  controller: _idController,
                  keyboardType: TextInputType.number,
                  // inputFormatters: membatasi karakter yang bisa diketik (hanya digit)
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'Masukkan Player ID PUBGM (angka)',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Icon(Icons.person, size: 24, color: Colors.grey.shade400), // Icon
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),

                const SizedBox(height: 20),

                // ===== KEUNGGULAN =====
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        children: const [
                          Icon(Icons.flash_on, color: Colors.orange),
                          SizedBox(height: 4),
                          Text('Instan'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: const [
                          Icon(Icons.security, color: Colors.orange),
                          SizedBox(height: 4),
                          Text('Aman'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: const [
                          Icon(Icons.support_agent, color: Colors.orange),
                          SizedBox(height: 4),
                          Text('Bantuan 24 Jam'),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ===== PILIH NOMINAL UC =====
                const Text('Pilih Nominal UC', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _barisPaket('60 UC', 15000, '325 UC', 75000),
                const SizedBox(height: 12),
                _barisPaket('660 UC', 150000, '1800 UC', 385000),
                const SizedBox(height: 12),
                _barisPaket('3850 UC', 765000, '8100 UC', 1525000),

                const SizedBox(height: 24),

                // ===== TOMBOL LANJUT KE HALAMAN KONFIRMASI =====
                // GestureDetector: mendeteksi ketukan pada tombol
                GestureDetector(
                  onTap: _lanjutKonfirmasi,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                      // BoxShadow: memberi efek bayangan pada tombol
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.shopping_cart, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Lanjut Top Up',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // BottomNavigationBar: navigasi bawah, sekarang punya onTap agar bisa pindah halaman
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.orange,
        // onTap: menangani ketukan pada tiap menu navigasi bawah
        onTap: (index) {
          if (index == 1) {
            // Navigator.push: membuka halaman Riwayat dan menambahkannya ke navigation stack
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RiwayatPage()),
            );
          } else if (index == 2) {
            // Navigator.push: membuka halaman Profil dan menambahkannya ke navigation stack
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilPage()),
            );
          }
          // index == 0 (Home) tidak melakukan apa-apa karena sudah berada di halaman ini
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// ======================================================
// HALAMAN 3: RIWAYAT PAGE (dibuka lewat Navigator.push dari BottomNavigationBar)
// ======================================================
class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil data riwayat transaksi yang sebenarnya dari AppState
    final riwayat = AppState.riwayat;

    // Scaffold: struktur dasar halaman riwayat
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        // leading: tombol kembali manual memakai Navigator.pop
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigator.pop: kembali ke halaman sebelumnya dari navigation stack
            Navigator.pop(context);
          },
        ),
      ),
      // SafeArea: memastikan konten tidak tertutup area sistem perangkat
      body: SafeArea(
        // Jika belum ada transaksi sama sekali, tampilkan pesan kosong
        child: riwayat.isEmpty
            ? Center(
                // Column: ikon dan teks pesan kosong disusun vertikal
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long, size: 56, color: Colors.grey.shade400), // Icon
                    const SizedBox(height: 12),
                    Text('Belum ada riwayat transaksi',
                        style: TextStyle(color: Colors.grey.shade600)), // Text
                  ],
                ),
              )
            // SingleChildScrollView: agar daftar riwayat bisa di-scroll
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  // Column: menyusun setiap kartu riwayat secara vertikal
                  child: Column(
                    children: riwayat.map((item) {
                // Padding: jarak antar kartu riwayat
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  // Container: kartu untuk satu item riwayat transaksi
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      // BoxShadow: bayangan halus pada kartu riwayat
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    // Row: ikon status di kiri, detail transaksi di kanan
                    child: Row(
                      children: [
                        // Icon: status transaksi (berhasil/diproses)
                        Icon(
                          item['status'] == 'Berhasil'
                              ? Icons.check_circle
                              : Icons.access_time,
                          color: item['status'] == 'Berhasil'
                              ? Colors.green
                              : Colors.orange,
                        ),
                        const SizedBox(width: 12), // SizedBox
                        // Expanded: detail transaksi mengisi sisa ruang baris
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Top Up ${item['uc']}',
                                  style: const TextStyle(fontWeight: FontWeight.bold)), // Text
                              const SizedBox(height: 2),
                              Text('ID ${item['id']} - ${item['status']}',
                                  style: TextStyle(color: Colors.grey.shade600)), // Text
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// ======================================================
// HALAMAN 4: PROFIL PAGE (dibuka lewat Navigator.push dari BottomNavigationBar)
// ======================================================
class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold: struktur dasar halaman profil
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Profil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigator.pop: kembali ke halaman sebelumnya (Home)
            Navigator.pop(context);
          },
        ),
      ),
      // SafeArea: memastikan konten tidak tertutup area sistem perangkat
      body: SafeArea(
        // Center: menempatkan isi profil di tengah layar
        child: Center(
          // Column: menyusun foto profil dan info akun secara vertikal
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Container: bingkai bulat untuk ikon profil, diberi BoxShadow
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange,
                  // BoxShadow: bayangan di sekitar foto profil
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.person, size: 48, color: Colors.white), // Icon
              ),
              const SizedBox(height: 16),
              const Text('Survivor Player',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Text
              const SizedBox(height: 4),
              Text('Player ID: 5123456789', style: TextStyle(color: Colors.grey.shade600)), // Text
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================
// HALAMAN 2: CONFIRM PAGE (dibuka lewat Navigator.push)
// ======================================================
class ConfirmPage extends StatelessWidget {
  final String playerId;
  final String uc;
  final int harga;

  const ConfirmPage({
    super.key,
    required this.playerId,
    required this.uc,
    required this.harga,
  });

  @override
  Widget build(BuildContext context) {
    // Scaffold: struktur dasar halaman konfirmasi
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Konfirmasi Top Up'),
        // leading: tombol kembali manual memakai Navigator.pop
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigator.pop: kembali ke halaman sebelumnya (Home) dari navigation stack
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== GAMBAR PRODUK (Stack + Positioned + Image) =====
                // Stack: menumpuk gambar produk dan label nama game
                SizedBox(
                  height: 140,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        // Image.asset: menampilkan logo/gambar game
                        child: Image.asset(
                          'assets/images/pubgm_logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.grey.shade800,
                            ),
                            child: const Center(
                              child: Icon(Icons.sports_esports, size: 48, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      // Positioned: label nama game di kiri bawah gambar
                      const Positioned(
                        left: 12,
                        bottom: 12,
                        child: Text(
                          'PUBG MOBILE',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text('Detail Pesanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // Container: kartu ringkasan detail pesanan
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    // BoxShadow: bayangan halus pada kartu ringkasan
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Player ID', style: TextStyle(color: Colors.grey.shade600)), // Text
                          Text(playerId, style: const TextStyle(fontWeight: FontWeight.bold)), // Text
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Paket', style: TextStyle(color: Colors.grey.shade600)), // Text
                          Text(uc, style: const TextStyle(fontWeight: FontWeight.bold)), // Text
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Bayar', style: TextStyle(color: Colors.grey.shade600)), // Text
                          Text('Rp$harga',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, color: Colors.orange)), // Text
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // ===== TOMBOL BAYAR DI BAWAH, DIBERI BOXSHADOW =====
      // Container: bar bawah berisi tombol bayar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          // BoxShadow: bayangan di atas bar bawah agar terlihat melayang
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () {
            // Menyimpan transaksi ini ke daftar riwayat lewat AppState
            AppState.tambahRiwayat(uc: uc, id: playerId, status: 'Berhasil');
            // Menampilkan notifikasi bahwa pembayaran berhasil
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pembayaran berhasil! Terima kasih.')),
            );
            // Navigator.pushReplacement: mengganti ConfirmPage dengan RiwayatPage
            // (mirip Navigator.push, tapi halaman ConfirmPage dihapus dari stack
            // sehingga tombol back di RiwayatPage langsung kembali ke Home)
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const RiwayatPage()),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Bayar Sekarang',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}