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
