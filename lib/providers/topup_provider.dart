import 'package:flutter/foundation.dart'; // ChangeNotifier
import '../models/paket_uc.dart';
import '../models/transaksi.dart';

// ======================================================
// TopUpProvider: pusat state bersama aplikasi (menggantikan lifting state up).
//
// Konsep Provider yang dipakai:
//  - ChangeNotifier : class dasar yang menyediakan mekanisme notifikasi perubahan.
//  - notifyListeners(): dipanggil setelah state berubah, supaya semua widget yang
//    mendengarkan (Consumer / context.watch / context.select) di-rebuild.
//
// State yang dikelola di sini (dipakai lebih dari satu halaman):
//  - currentIndex   : tab BottomNavigationBar aktif
//  - playerId       : Player ID yang dipakai untuk top up (dibaca ProfilPage)
//  - idText         : teks Player ID yang sedang diketik di HomePage
//  - searchQuery    : kata kunci pencarian paket
//  - selectedPaket  : paket UC yang dipilih
//  - nama           : nama profil
//  - notifAktif     : saklar notifikasi promo
//  - riwayat        : daftar transaksi
// ======================================================
class TopUpProvider extends ChangeNotifier {
  // Daftar semua paket UC yang dijual
  static const List<PaketUc> semuaPaket = [
    PaketUc('60 UC', 15000),
    PaketUc('325 UC', 75000),
    PaketUc('660 UC', 150000),
    PaketUc('1800 UC', 385000),
    PaketUc('3850 UC', 765000),
    PaketUc('8100 UC', 1525000),
  ];

  int _currentIndex = 0;
  String _playerId = '';
  String _idText = '';
  String _searchQuery = '';
  PaketUc? _selectedPaket;
  String _nama = 'Survivor Player';
  bool _notifAktif = true;
  final List<Transaksi> _riwayat = [];
  bool _disposed = false; // mencegah notifyListeners() setelah provider dibuang

  // ----- Getter (UI hanya membaca, tidak mengubah langsung) -----
  int get currentIndex => _currentIndex;
  String get playerId => _playerId;
  String get idText => _idText;
  String get searchQuery => _searchQuery;
  PaketUc? get selectedPaket => _selectedPaket;
  String get nama => _nama;
  bool get notifAktif => _notifAktif;
  List<Transaksi> get riwayat => List.unmodifiable(_riwayat);

  // ----- Derived state: dihitung dari state lain, tidak disimpan terpisah -----
  // Player ID valid jika 8-12 digit
  bool get idValid => _idText.length >= 8 && _idText.length <= 12;

  // Tombol lanjut aktif hanya jika ID valid dan paket sudah dipilih
  bool get bisaLanjut => idValid && _selectedPaket != null;

  // Paket yang tampil setelah difilter oleh kata kunci pencarian
  List<PaketUc> get paketTampil => semuaPaket
      .where((p) => p.nama.toLowerCase().contains(_searchQuery))
      .toList();

  // Statistik profil
  int get jumlahTransaksi => _riwayat.length;
  int get totalBelanja => _riwayat.fold<int>(0, (sum, t) => sum + t.harga);

  // ----- Aksi (mengubah state lalu memanggil notifyListeners) -----
  void setTab(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void setIdText(String value) {
    _idText = value;
    notifyListeners();
  }

  void setSearchQuery(String value) {
    _searchQuery = value.toLowerCase().trim();
    notifyListeners();
  }

  void pilihPaket(PaketUc paket) {
    _selectedPaket = paket;
    notifyListeners();
  }

  // Menyimpan Player ID yang dipakai (dibaca oleh ProfilPage)
  void simpanPlayerId() {
    _playerId = _idText;
    notifyListeners();
  }

  void setNama(String value) {
    _nama = value;
    notifyListeners();
  }

  void setNotif(bool value) {
    _notifAktif = value;
    notifyListeners();
  }

  // Dipanggil dari ConfirmPage setelah user menekan "Bayar Sekarang"
  void tambahTransaksi(PaketUc paket, String playerId, String metode) {
    final transaksi = Transaksi(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      uc: paket.nama,
      playerId: playerId,
      harga: paket.harga,
      metode: metode,
      waktu: DateTime.now(),
      status: 'Diproses',
    );
    _riwayat.insert(0, transaksi); // index 0 supaya transaksi terbaru di atas
    _currentIndex = 1; // pindah ke tab Riwayat
    notifyListeners();

    // Konsep di luar modul: Future.delayed untuk mensimulasikan proses server.
    // Setelah 3 detik status berubah menjadi 'Berhasil' dan UI ikut berubah.
    Future.delayed(const Duration(seconds: 3), () {
      if (_disposed) return; // cegah notifyListeners jika provider sudah dibuang
      transaksi.status = 'Berhasil';
      notifyListeners();
    });
  }

  // Menghapus satu transaksi berdasarkan id
  void hapusTransaksi(String id) {
    _riwayat.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  // Menghapus seluruh riwayat
  void hapusSemua() {
    _riwayat.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
