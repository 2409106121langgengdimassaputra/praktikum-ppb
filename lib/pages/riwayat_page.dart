import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/topup_provider.dart';
import '../utils/format.dart';

// ======================================================
// HALAMAN 3: RIWAYAT PAGE
// State lokal (setState): _filter (hanya dipakai halaman ini).
// Data riwayat dimiliki TopUpProvider dan dibaca lewat Consumer.
// ======================================================
class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

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
    if (yakin == true && mounted) context.read<TopUpProvider>().hapusSemua(); // aksi provider
  }

  @override
  Widget build(BuildContext context) {
    // Consumer: halaman rebuild otomatis saat riwayat berubah
    // (termasuk saat status transaksi berubah menjadi 'Berhasil')
    return Consumer<TopUpProvider>(
      builder: (context, topup, child) {
        final riwayat = topup.riwayat;
        // Derived state: riwayat yang tampil sesuai filter
        final tampil = _filter == 'Semua'
            ? riwayat
            : riwayat.where((t) => t.status == _filter).toList();

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
            onPressed: riwayat.isEmpty ? null : _konfirmasiHapusSemua,
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
                                  onPressed: () =>
                                      context.read<TopUpProvider>().hapusTransaksi(item.id),
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
      },
    );
  }
}
