
class AppState {
  // Player ID terakhir yang diinput user di HomePage
  static String playerId = '';

  // Daftar riwayat transaksi top up (tersimpan selama aplikasi berjalan)
  static List<Map<String, String>> riwayat = [];

  // Fungsi untuk menambahkan satu transaksi baru ke riwayat.
  // Dipanggil dari ConfirmPage setelah user menekan "Bayar Sekarang".
  static void tambahRiwayat({
    required String uc,
    required String id,
    required String status,
  }) {
    // insert di index 0 supaya transaksi terbaru muncul paling atas
    riwayat.insert(0, {'uc': uc, 'id': id, 'status': status});
  }
}