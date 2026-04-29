import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';

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

  // RLS policies bergantung pada auth.uid() — tanpa session anonymous,
  // insert ke `bills` ditolak (42501). Anonymous sign-in harus diaktifkan
  // di Supabase Dashboard → Authentication → Providers → Anonymous sign-ins.
  // Kalau langkah ini gagal di release (mis. Anonymous disabled atau jaringan
  // mati), kita lanjut tanpa session: app tetap bisa dibuka, dan request yang
  // butuh auth akan mengembalikan error yang terbaca user — jauh lebih baik
  // daripada stuck di splash selamanya.
  try {
    final auth = Supabase.instance.client.auth;
    if (auth.currentUser == null) {
      await auth.signInAnonymously().timeout(const Duration(seconds: 10));
    }
  } catch (e) {
    debugPrint('signInAnonymously failed: $e');
  }

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
