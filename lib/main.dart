import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env (bundled as an asset). Crashing here is intentional — without
  // Supabase credentials the app cannot do anything useful.
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  // Pastikan user selalu punya session — RLS policies bergantung pada
  // auth.uid(). Tanpa ini, insert ke `bills` ditolak (42501) karena
  // `owner_id DEFAULT auth.uid()` jadi NULL untuk request unauthenticated.
  // Anonymous sign-in harus diaktifkan di Supabase Dashboard:
  // Authentication → Providers → Anonymous sign-ins.
  final auth = Supabase.instance.client.auth;
  if (auth.currentUser == null) {
    await auth.signInAnonymously();
  }

  runApp(const ProviderScope(child: BagiStrukApp()));
}
