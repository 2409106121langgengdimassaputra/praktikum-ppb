import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // untuk membatasi input TextField hanya angka
import 'app_state.dart'; // model PaketUc, Transaksi, dan helper formatRupiah

// Fungsi utama: titik awal aplikasi Flutter
void main() {
  runApp(const TopUpApp());
}

// StatelessWidget: root app tidak punya data yang berubah, hanya membungkus tema
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
      home: const MainShell(), // kerangka utama yang memegang semua state bersama
    );
  }
}

// ======================================================
// MAIN SHELL: pemilik state bersama (lifting state up)
// State yang dipegang di sini:
//  - _currentIndex : tab BottomNavigationBar yang aktif
//  - _playerId     : Player ID terakhir yang dipakai (dibaca ProfilPage)
//  - _nama         : nama profil (bisa diedit di ProfilPage)
//  - _riwayat      : daftar transaksi (dibaca & dihapus di RiwayatPage)
// ======================================================
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  String _playerId = '';
  String _nama = 'Survivor Player';
  final List<Transaksi> _riwayat = [];

  // Dipanggil dari ConfirmPage setelah user menekan "Bayar Sekarang"
  void _tambahTransaksi(PaketUc paket, String playerId, String metode) {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final transaksi = Transaksi(
      id: id,
      uc: paket.nama,
      playerId: playerId,
      harga: paket.harga,
      metode: metode,
      waktu: DateTime.now(),
      status: 'Diproses',
    );
    // setState: tambah transaksi baru + pindah ke tab Riwayat
    setState(() {
      _riwayat.insert(0, transaksi); // index 0 supaya transaksi terbaru di atas
      _currentIndex = 1;
    });

    // Konsep di luar modul: Future.delayed untuk mensimulasikan proses server.
    // Setelah 3 detik status berubah menjadi 'Berhasil' dan UI ikut berubah.
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return; // cegah setState jika widget sudah dibuang
      setState(() => transaksi.status = 'Berhasil');
    });
  }

  // Menghapus satu transaksi berdasarkan id
  void _hapusTransaksi(String id) {
    setState(() => _riwayat.removeWhere((t) => t.id == id));
  }

  // Menghapus seluruh riwayat
  void _hapusSemua() {
    setState(() => _riwayat.clear());
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold: struktur dasar halaman yang berisi body dan navigasi bawah
    return Scaffold(
      // IndexedStack: menampilkan satu halaman sesuai index, tetapi state
      // halaman lain (misal teks Player ID di Home) tetap terjaga.
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomePage(
            onPlayerIdChanged: (id) => setState(() => _playerId = id),
            onPaid: _tambahTransaksi,
          ),
          RiwayatPage(
            riwayat: _riwayat,
            onHapus: _hapusTransaksi,
            onHapusSemua: _hapusSemua,
          ),
          ProfilPage(
            nama: _nama,
            playerId: _playerId,
            riwayat: _riwayat,
            onNamaChanged: (nama) => setState(() => _nama = nama),
          ),
        ],
      ),
      // BottomNavigationBar: currentIndex sekarang bergantung pada state
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.orange,
        // onTap: mengubah state _currentIndex lewat setState
        onTap: (index) => setState(() => _currentIndex = index),
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
// HALAMAN 1: HOME PAGE
// State lokal: _idController, _idText, _searchQuery, _selectedPaket
// Derived state: _idValid, visiblePaket, _bisaLanjut
// ======================================================
class HomePage extends StatefulWidget {
  final ValueChanged<String> onPlayerIdChanged; // callback ke MainShell
  final void Function(PaketUc paket, String playerId, String metode) onPaid;

  const HomePage({
    super.key,
    required this.onPlayerIdChanged,
    required this.onPaid,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Daftar semua paket UC yang dijual
  static const List<PaketUc> _semuaPaket = [
    PaketUc('60 UC', 15000),
    PaketUc('325 UC', 75000),
    PaketUc('660 UC', 150000),
    PaketUc('1800 UC', 385000),
    PaketUc('3850 UC', 765000),
    PaketUc('8100 UC', 1525000),
  ];

  final TextEditingController _idController = TextEditingController();
  String _idText = ''; // salinan teks Player ID sebagai state
  String _searchQuery = ''; // kata kunci pencarian paket
  PaketUc? _selectedPaket; // paket yang dipilih (null = belum memilih)

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  // Derived state: Player ID valid jika 8-12 digit (tidak disimpan, dihitung dari _idText)
  bool get _idValid => _idText.length >= 8 && _idText.length <= 12;

  // Derived state: tombol aktif hanya jika ID valid dan paket sudah dipilih
  bool get _bisaLanjut => _idValid && _selectedPaket != null;

  // Fungsi pembuat kartu paket UC (dipakai berulang)
  Widget _kartuPaket(PaketUc paket) {
    final selected = _selectedPaket?.nama == paket.nama;
    // GestureDetector: mendeteksi ketukan pada kartu paket
    return GestureDetector(
      // setState: menyimpan paket yang dipilih lalu rebuild UI
      onTap: () => setState(() => _selectedPaket = paket),
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
    widget.onPlayerIdChanged(_idText); // kirim Player ID ke MainShell (untuk ProfilPage)
    // Navigator.push: membuka ConfirmPage dan menambahkannya ke navigation stack
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmPage(
          playerId: _idText,
          paket: _selectedPaket!,
          onPaid: (metode) => widget.onPaid(_selectedPaket!, _idText, metode),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Derived state: daftar paket yang tampil, difilter dari _searchQuery
    final visiblePaket = _semuaPaket
        .where((p) => p.nama.toLowerCase().contains(_searchQuery))
        .toList();

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
                // TextField: onChanged menyimpan teks ke state _idText setiap user mengetik
                TextField(
                  controller: _idController,
                  keyboardType: TextInputType.number,
                  // inputFormatters: hanya digit, maksimal 12 karakter
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(12),
                  ],
                  onChanged: (value) => setState(() => _idText = value),
                  decoration: InputDecoration(
                    hintText: 'Masukkan Player ID PUBGM (8-12 angka)',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: Colors.white,
                    // errorText: muncul otomatis dari derived state _idValid
                    errorText: _idText.isNotEmpty && !_idValid
                        ? 'Player ID harus 8-12 digit'
                        : null,
                    // suffixIcon: ikon berubah menjadi centang jika ID valid
                    suffixIcon: Icon(
                      _idValid ? Icons.check_circle : Icons.person,
                      color: _idValid ? Colors.green : Colors.grey.shade400,
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
                // TextField pencarian: onChanged mengubah _searchQuery lewat setState
                TextField(
                  onChanged: (value) =>
                      setState(() => _searchQuery = value.toLowerCase().trim()),
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
                    children: visiblePaket.map(_kartuPaket).toList(),
                  ),

                const SizedBox(height: 16),

                // ===== RINGKASAN PILIHAN (muncul hanya jika ada paket terpilih) =====
                if (_selectedPaket != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Dipilih: ${_selectedPaket!.nama} - ${formatRupiah(_selectedPaket!.harga)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ), // Text
                  ),

                const SizedBox(height: 16),

                // ===== TOMBOL LANJUT =====
                // SizedBox: membuat tombol selebar layar
                SizedBox(
                  width: double.infinity,
                  // ElevatedButton: onPressed null = tombol nonaktif (derived state _bisaLanjut)
                  child: ElevatedButton.icon(
                    onPressed: _bisaLanjut ? _lanjutKonfirmasi : null,
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
  }
}

// ======================================================
// HALAMAN 2: CONFIRM PAGE
// State lokal: _metode, _setuju, _isLoading
// ======================================================
class ConfirmPage extends StatefulWidget {
  final String playerId;
  final PaketUc paket;
  final ValueChanged<String> onPaid; // callback ke MainShell dengan metode bayar

  const ConfirmPage({
    super.key,
    required this.playerId,
    required this.paket,
    required this.onPaid,
  });

  @override
  State<ConfirmPage> createState() => _ConfirmPageState();
}

class _ConfirmPageState extends State<ConfirmPage> {
  static const List<String> _daftarMetode = ['DANA', 'OVO', 'GoPay', 'Transfer Bank'];

  String? _metode; // metode pembayaran terpilih (null = belum memilih)
  bool _setuju = false; // status checkbox syarat & ketentuan
  bool _isLoading = false; // true saat proses pembayaran berjalan

  // Derived state: tombol bayar aktif jika metode dipilih, setuju dicentang, dan tidak loading
  bool get _bisaBayar => _metode != null && _setuju && !_isLoading;

  Future<void> _bayar() async {
    // Simpan messenger & navigator sebelum await (aman dipakai setelah proses async)
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isLoading = true); // tampilkan loading

    // Konsep di luar modul: async/await + Future.delayed untuk mensimulasikan pembayaran
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    widget.onPaid(_metode!); // kirim transaksi ke MainShell (setState di sana)
    navigator.pop(); // kembali ke halaman utama (yang sudah pindah ke tab Riwayat)
    // SnackBar: notifikasi pembayaran berhasil
    messenger.showSnackBar(
      const SnackBar(content: Text('Pembayaran berhasil! Terima kasih.')),
    );
  }

  // Helper: satu baris "label ... nilai" pada kartu ringkasan
  Widget _baris(String label, String nilai, {Color? warna}) {
    // Row: label di kiri, nilai di kanan
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600)), // Text
        Text(nilai, style: TextStyle(fontWeight: FontWeight.bold, color: warna)), // Text
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold: struktur dasar halaman konfirmasi
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      // AppBar: judul halaman (tombol back otomatis dari Navigator)
      appBar: AppBar(title: const Text('Konfirmasi Top Up')),
      // SafeArea: konten tidak tertutup area sistem
      body: SafeArea(
        // SingleChildScrollView: agar halaman bisa di-scroll
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== GAMBAR PRODUK (Stack + Positioned + Image) =====
                SizedBox(
                  height: 140,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        // Image.asset: logo game, dengan tampilan cadangan jika aset tidak ada
                        child: Image.asset(
                          'assets/images/pubgm_logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.grey.shade800,
                            ),
                            child: const Center(
                              child: Icon(Icons.sports_esports,
                                  size: 48, color: Colors.white), // Icon
                            ),
                          ),
                        ),
                      ),
                      // Positioned: label nama game di kiri bawah
                      const Positioned(
                        left: 12,
                        bottom: 12,
                        child: Text('PUBG MOBILE',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)), // Text
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const Text('Detail Pesanan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // Text
                const SizedBox(height: 12),

                // Container: kartu ringkasan detail pesanan
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    // BoxShadow: bayangan halus pada kartu
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _baris('Player ID', widget.playerId),
                      const SizedBox(height: 8),
                      _baris('Paket', widget.paket.nama),
                      const SizedBox(height: 8),
                      _baris('Total Bayar', formatRupiah(widget.paket.harga),
                          warna: Colors.orange),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const Text('Metode Pembayaran',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // Text
                const SizedBox(height: 12),
                // Wrap: chip otomatis turun baris jika layar sempit
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _daftarMetode.map((m) {
                    // ChoiceChip: pilihan tunggal; selected mengikuti state _metode
                    return ChoiceChip(
                      label: Text(m), // Text
                      selected: _metode == m,
                      selectedColor: Colors.orange.shade200,
                      // setState: simpan metode terpilih
                      onSelected: _isLoading
                          ? null
                          : (_) => setState(() => _metode = m),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),
                // CheckboxListTile: persetujuan syarat, nilainya disimpan di state _setuju
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.orange,
                  value: _setuju,
                  onChanged: _isLoading
                      ? null
                      : (value) => setState(() => _setuju = value ?? false),
                  title: const Text('Data yang saya masukkan sudah benar'), // Text
                ),
              ],
            ),
          ),
        ),
      ),
      // ===== TOMBOL BAYAR DI BAWAH =====
      // Container: bar bawah berisi tombol bayar, diberi BoxShadow
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        // SafeArea: tombol tidak tertutup gesture bar
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            // ElevatedButton: nonaktif (null) sampai semua syarat terpenuhi
            child: ElevatedButton(
              onPressed: _bisaBayar ? _bayar : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              // Isi tombol berubah: spinner saat loading, teks saat normal
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white), // loading indicator
                    )
                  : const Text('Bayar Sekarang',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // Text
            ),
          ),
        ),
      ),
    );
  }
}

// ======================================================
// HALAMAN 3: RIWAYAT PAGE
// State lokal: _filter. Data riwayat dimiliki MainShell (lifting state up).
// ======================================================
class RiwayatPage extends StatefulWidget {
  final List<Transaksi> riwayat;
  final ValueChanged<String> onHapus; // callback hapus satu transaksi
  final VoidCallback onHapusSemua; // callback hapus semua

  const RiwayatPage({
    super.key,
    required this.riwayat,
    required this.onHapus,
    required this.onHapusSemua,
  });

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  static const List<String> _opsiFilter = ['Semua', 'Diproses', 'Berhasil'];
  String _filter = 'Semua'; // filter status yang sedang aktif

  // Dialog konfirmasi sebelum menghapus semua riwayat
  Future<void> _konfirmasiHapusSemua() async {
    // showDialog: menampilkan AlertDialog, hasilnya true/false
    final yakin = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus semua riwayat?'), // Text
        content: const Text('Tindakan ini tidak dapat dibatalkan.'), // Text
        actions: [
          // TextButton: tombol teks untuk batal / hapus
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'), // Text
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'), // Text
          ),
        ],
      ),
    );
    if (yakin == true) widget.onHapusSemua();
  }

  @override
  Widget build(BuildContext context) {
    // Derived state: riwayat yang tampil sesuai filter
    final tampil = _filter == 'Semua'
        ? widget.riwayat
        : widget.riwayat.where((t) => t.status == _filter).toList();

    // Scaffold: struktur dasar halaman riwayat
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      // AppBar: tombol hapus semua hanya aktif jika riwayat tidak kosong
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'), // Text
        actions: [
          // IconButton: onPressed null = nonaktif (derived state)
          IconButton(
            tooltip: 'Hapus semua',
            icon: const Icon(Icons.delete_sweep), // Icon
            onPressed: widget.riwayat.isEmpty ? null : _konfirmasiHapusSemua,
          ),
        ],
      ),
      // SafeArea: konten tidak tertutup area sistem
      body: SafeArea(
        // Column: baris filter di atas, daftar di bawah
        child: Column(
          children: [
            // Padding + Wrap: deretan chip filter status
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Wrap(
                spacing: 8,
                children: _opsiFilter.map((f) {
                  // ChoiceChip: filter aktif mengikuti state _filter
                  return ChoiceChip(
                    label: Text(f), // Text
                    selected: _filter == f,
                    selectedColor: Colors.orange.shade200,
                    onSelected: (_) => setState(() => _filter = f),
                  );
                }).toList(),
              ),
            ),
            // Expanded: daftar mengisi sisa tinggi layar
            Expanded(
              child: tampil.isEmpty
                  ? Center(
                      // Column: ikon dan teks pesan kosong
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.receipt_long,
                              size: 56, color: Colors.grey.shade400), // Icon
                          const SizedBox(height: 12),
                          Text('Belum ada riwayat transaksi',
                              style: TextStyle(color: Colors.grey.shade600)), // Text
                        ],
                      ),
                    )
                  // ListView.builder: membangun kartu hanya yang terlihat (efisien)
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: tampil.length,
                      itemBuilder: (context, index) {
                        final item = tampil[index];
                        final berhasil = item.status == 'Berhasil';
                        // Padding: jarak antar kartu
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          // Container: kartu satu transaksi
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            // Row: ikon status, detail, tombol hapus
                            child: Row(
                              children: [
                                // Icon: berubah dari jam ke centang saat status berubah
                                Icon(
                                  berhasil ? Icons.check_circle : Icons.access_time,
                                  color: berhasil ? Colors.green : Colors.orange,
                                ),
                                const SizedBox(width: 12),
                                // Expanded: detail mengisi sisa ruang baris
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Top Up ${item.uc}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)), // Text
                                      const SizedBox(height: 2),
                                      Text(
                                          'ID ${item.playerId} - ${item.metode} - ${formatRupiah(item.harga)}',
                                          style: TextStyle(
                                              color: Colors.grey.shade600)), // Text
                                      Text(item.status,
                                          style: TextStyle(
                                              color: berhasil
                                                  ? Colors.green
                                                  : Colors.orange)), // Text
                                    ],
                                  ),
                                ),
                                // IconButton: hapus satu transaksi
                                IconButton(
                                  icon: const Icon(Icons.delete_outline), // Icon
                                  onPressed: () => widget.onHapus(item.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// HALAMAN 4: PROFIL PAGE
// State lokal: _namaController, _editMode, _notifAktif
// Memakai lifecycle: initState, didUpdateWidget, dispose
// ======================================================
class ProfilPage extends StatefulWidget {
  final String nama;
  final String playerId;
  final List<Transaksi> riwayat;
  final ValueChanged<String> onNamaChanged; // callback simpan nama ke MainShell

  const ProfilPage({
    super.key,
    required this.nama,
    required this.playerId,
    required this.riwayat,
    required this.onNamaChanged,
  });

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  late TextEditingController _namaController;
  bool _editMode = false; // true saat user sedang mengedit nama
  bool _notifAktif = true; // status Switch notifikasi

  // initState: dijalankan sekali saat state dibuat, mengisi controller dengan nilai awal
  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.nama);
  }

  // didUpdateWidget: menyamakan controller jika nama berubah dari luar saat tidak mengedit
  @override
  void didUpdateWidget(covariant ProfilPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editMode && oldWidget.nama != widget.nama) {
      _namaController.text = widget.nama;
    }
  }

  // dispose: membersihkan controller agar tidak terjadi memory leak
  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  // Menyimpan nama baru (validasi: tidak boleh kosong)
  void _simpanNama() {
    final baru = _namaController.text.trim();
    if (baru.isEmpty) return; // tolak input kosong
    widget.onNamaChanged(baru);
    setState(() => _editMode = false);
  }

  @override
  Widget build(BuildContext context) {
    // Derived state: statistik dihitung dari riwayat, tidak disimpan terpisah
    final totalBelanja = widget.riwayat.fold<int>(0, (sum, t) => sum + t.harga);

    // Scaffold: struktur dasar halaman profil
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: const Text('Profil')), // AppBar + Text
      // SafeArea: konten tidak tertutup area sistem
      body: SafeArea(
        // SingleChildScrollView: agar aman di layar kecil
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            // Column: avatar, nama, statistik, pengaturan
            child: Column(
              children: [
                // Container: bingkai bulat avatar dengan BoxShadow
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange,
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

                // Mode edit: TextField + tombol simpan. Mode biasa: teks nama + tombol edit.
                if (_editMode)
                  // Row: input nama dan tombol simpan sejajar
                  Row(
                    children: [
                      // Expanded: TextField mengisi sisa lebar
                      Expanded(
                        child: TextField(
                          controller: _namaController,
                          autofocus: true,
                          decoration: InputDecoration(
                            labelText: 'Nama profil',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      // IconButton: simpan nama
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green), // Icon
                        onPressed: _simpanNama,
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.nama,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)), // Text
                      // IconButton: masuk ke mode edit
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18), // Icon
                        onPressed: () => setState(() => _editMode = true),
                      ),
                    ],
                  ),
                const SizedBox(height: 4),
                // Player ID dibaca dari state MainShell; '-' jika belum pernah top up
                Text(
                    'Player ID: ${widget.playerId.isEmpty ? '-' : widget.playerId}',
                    style: TextStyle(color: Colors.grey.shade600)), // Text

                const SizedBox(height: 24),

                // Container: kartu statistik (derived state dari riwayat)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Row: label kiri, nilai kanan
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Jumlah transaksi'), // Text
                          Text('${widget.riwayat.length}',
                              style: const TextStyle(fontWeight: FontWeight.bold)), // Text
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total belanja'), // Text
                          Text(formatRupiah(totalBelanja),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange)), // Text
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // SwitchListTile: saklar notifikasi, nilainya disimpan di state _notifAktif
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SwitchListTile(
                    activeThumbColor: Colors.orange,
                    title: const Text('Notifikasi promo'), // Text
                    subtitle: Text(_notifAktif ? 'Aktif' : 'Nonaktif'), // Text
                    value: _notifAktif,
                    onChanged: (value) => setState(() => _notifAktif = value),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}