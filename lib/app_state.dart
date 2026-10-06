// ======================================================
// MODEL DATA & HELPER
// File ini tidak lagi menyimpan state global (static).
// State sekarang disimpan di _MainShellState (main.dart) memakai setState,
// lalu dikirim ke halaman anak lewat constructor + callback (lifting state up).
// ======================================================

// Model satu paket UC yang dijual
class PaketUc {
  final String nama; // contoh: '60 UC'
  final int harga; // harga dalam rupiah

  const PaketUc(this.nama, this.harga);
}

// Model satu transaksi top up
class Transaksi {
  final String id; // id unik transaksi (dipakai untuk menghapus / update status)
  final String uc;
  final String playerId;
  final int harga;
  final String metode;
  final DateTime waktu;
  String status; // 'Diproses' -> 'Berhasil' (berubah selama aplikasi berjalan = state)

  Transaksi({
    required this.id,
    required this.uc,
    required this.playerId,
    required this.harga,
    required this.metode,
    required this.waktu,
    required this.status,
  });
}

// Helper format rupiah: 1525000 -> 'Rp1.525.000'
// Konsep di luar modul: RegExp + replaceAllMapped untuk menyisipkan titik ribuan.
String formatRupiah(int angka) {
  final teks = angka.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => '.',
      );
  return 'Rp$teks';
}