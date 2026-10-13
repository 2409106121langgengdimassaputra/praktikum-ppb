import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/topup_provider.dart';
import '../utils/format.dart';

// ======================================================
// HALAMAN 4: PROFIL PAGE
// State lokal (setState): _namaController, _editMode (hanya untuk UI edit).
// State bersama (Provider): nama, playerId, statistik riwayat, notifAktif.
// Memakai lifecycle: initState, dispose
// ======================================================
class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  late TextEditingController _namaController;
  bool _editMode = false; // true saat user sedang mengedit nama

  // initState: dijalankan sekali saat state dibuat, mengisi controller dengan nilai awal.
  // context.read dipakai karena initState tidak boleh mendengarkan (watch) provider.
  @override
  void initState() {
    super.initState();
    _namaController =
        TextEditingController(text: context.read<TopUpProvider>().nama);
  }

  // dispose: membersihkan controller agar tidak terjadi memory leak
  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  // Masuk mode edit: isi controller dengan nama terbaru dari provider
  void _mulaiEdit() {
    _namaController.text = context.read<TopUpProvider>().nama;
    setState(() => _editMode = true);
  }

  // Menyimpan nama baru ke provider (validasi: tidak boleh kosong)
  void _simpanNama() {
    final baru = _namaController.text.trim();
    if (baru.isEmpty) return; // tolak input kosong
    context.read<TopUpProvider>().setNama(baru);
    setState(() => _editMode = false);
  }

  @override
  Widget build(BuildContext context) {
    // Consumer: halaman rebuild otomatis saat nama, riwayat, atau notifikasi berubah
    return Consumer<TopUpProvider>(
      builder: (context, topup, child) {
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
                      Text(topup.nama,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)), // Text
                      // IconButton: masuk ke mode edit
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18), // Icon
                        onPressed: _mulaiEdit,
                      ),
                    ],
                  ),
                const SizedBox(height: 4),
                // Player ID dibaca dari TopUpProvider; '-' jika belum pernah top up
                Text(
                    'Player ID: ${topup.playerId.isEmpty ? '-' : topup.playerId}',
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
                          Text('${topup.jumlahTransaksi}',
                              style: const TextStyle(fontWeight: FontWeight.bold)), // Text
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total belanja'), // Text
                          Text(formatRupiah(topup.totalBelanja),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange)), // Text
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // SwitchListTile: saklar notifikasi, nilainya disimpan di provider (notifAktif)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SwitchListTile(
                    activeThumbColor: Colors.orange,
                    title: const Text('Notifikasi promo'), // Text
                    subtitle: Text(topup.notifAktif ? 'Aktif' : 'Nonaktif'), // Text
                    value: topup.notifAktif,
                    onChanged: (value) => context.read<TopUpProvider>().setNotif(value),
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
