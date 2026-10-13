# TopUp UC PUBGM

Aplikasi Flutter simulasi top up UC PUBG Mobile dengan state management **Provider**.

## Fitur
- Input Player ID (validasi 8-12 digit), pencarian dan pemilihan paket UC
- Konfirmasi pesanan, pilih metode pembayaran, simulasi pembayaran
- Riwayat transaksi (status Diproses -> Berhasil otomatis, filter, hapus satu/semua)
- Profil (edit nama, statistik transaksi, saklar notifikasi)

## State Management: Provider
| Konsep | Lokasi | Fungsi |
|---|---|---|
| `ChangeNotifier` | `lib/providers/topup_provider.dart` | Menyimpan state bersama + `notifyListeners()` |
| `MultiProvider` + `ChangeNotifierProvider` | `lib/main.dart` | Mendaftarkan dan menyediakan `TopUpProvider` |
| `Consumer` | Home, Riwayat, Profil | Rebuild UI saat state berubah |
| `context.select` | `lib/pages/main_shell.dart` | Rebuild hanya jika tab aktif berubah |
| `context.read` | Semua aksi (onTap, onPressed) | Memanggil fungsi provider tanpa mendengarkan |

## Struktur
```
lib/
  main.dart
  models/        paket_uc.dart, transaksi.dart
  providers/     topup_provider.dart
  pages/         main_shell.dart, home_page.dart, confirm_page.dart,
                 riwayat_page.dart, profil_page.dart
  utils/         format.dart
```

## Menjalankan
```
flutter clean
flutter pub get
flutter run
```
