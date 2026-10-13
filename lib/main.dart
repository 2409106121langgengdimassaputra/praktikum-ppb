import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // package State Management: Provider
import 'pages/main_shell.dart';
import 'providers/topup_provider.dart';

// Fungsi utama: titik awal aplikasi Flutter
void main() {
  runApp(
    // MultiProvider: tempat mendaftarkan satu atau lebih provider di atas MaterialApp,
    // sehingga semua halaman (termasuk yang dibuka lewat Navigator.push) bisa mengaksesnya.
    MultiProvider(
      providers: [
        // ChangeNotifierProvider: membuat satu instance TopUpProvider dan
        // menyediakannya ke seluruh widget di bawahnya.
        ChangeNotifierProvider(create: (_) => TopUpProvider()),
      ],
      child: const TopUpApp(),
    ),
  );
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
      home: const MainShell(), // kerangka utama dengan navigasi bawah
    );
  }
}
