import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/paket_uc.dart';
import '../providers/topup_provider.dart';
import '../utils/format.dart';

// ======================================================
// HALAMAN 2: CONFIRM PAGE
// State lokal (setState): _metode, _setuju, _isLoading (hanya dipakai halaman ini).
// Saat bayar, halaman memanggil TopUpProvider.tambahTransaksi() lewat context.read.
// ======================================================
class ConfirmPage extends StatefulWidget {
  final String playerId;
  final PaketUc paket;

  const ConfirmPage({
    super.key,
    required this.playerId,
    required this.paket,
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

    // context.read: kirim transaksi ke provider (tanpa mendengarkan perubahan).
    // Provider yang memindahkan tab ke Riwayat dan menjalankan status 'Diproses' -> 'Berhasil'.
    context.read<TopUpProvider>().tambahTransaksi(
          widget.paket,
          widget.playerId,
          _metode!,
        );
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
