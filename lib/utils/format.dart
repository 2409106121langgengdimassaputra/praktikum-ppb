// Helper format rupiah: 1525000 -> 'Rp1.525.000'
// Konsep di luar modul: RegExp + replaceAllMapped untuk menyisipkan titik ribuan.
String formatRupiah(int angka) {
  final teks = angka.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => '.',
      );
  return 'Rp$teks';
}
