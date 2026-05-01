import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'core/format/app_format.dart';

/// Entry point.
///
/// Defensive flow: every step that can hang the splash (asset load, network
/// init, anonymous sign-in) is bounded by a timeout and wrapped so failures
/// surface as a visible error screen instead of a frozen Flutter logo.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final initError = await _bootstrap();

  if (initError != null) {
    runApp(_StartupErrorApp(error: initError));
    return;
  }

  runApp(const ProviderScope(child: BagiStrukApp()));
}

Future<String?> _bootstrap() async {
  // Default ke Indonesian — currency Rupiah, tanggal Indonesia. Inisialisasi
  // date symbols sekali di awal supaya DateFormat('id_ID') tidak throw.
  Intl.defaultLocale = AppFormat.locale;
  await initializeDateFormatting(AppFormat.locale);

  try {
    await dotenv.load(fileName: '.env').timeout(const Duration(seconds: 5));
  } catch (e) {
    return 'Gagal memuat konfigurasi (.env): $e';
  }

  try {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    ).timeout(const Duration(seconds: 10));
  } catch (e) {
    return 'Gagal inisialisasi Supabase: $e';
  }

  // Sengaja TIDAK eager-anonymous sign-in di sini. supabase_flutter sudah
  // memulihkan session yang disimpan saat `Supabase.initialize()` selesai;
  // memaksa `signInAnonymously()` lagi akan menimpa session login email
  // yang baru di-restore (race condition). Anonymous sign-in dilakukan
  // secara lazy — lihat `IAuthRepository.ensureSignedIn()` yang dipanggil
  // sebelum aksi yang butuh `auth.uid()` (mis. proses OCR / simpan bill).

  return null;
}

class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline,
                    size: 56, color: Colors.redAccent),
                const SizedBox(height: 16),
                const Text(
                  'BagiStruk gagal dimulai',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(error, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 24),
                const Text(
                  'Cek koneksi internet, lalu buka ulang aplikasi. Kalau '
                  'masih bermasalah, periksa file .env dan setting Supabase.',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
