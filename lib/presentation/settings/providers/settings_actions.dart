import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/result.dart';
import '../../../data/providers.dart';
import '../../bills/providers/bill_list_notifier.dart';
import 'profile_notifier.dart';

/// Signs the user out, invalidates every user-scoped Riverpod cache, then
/// re-establishes a fresh anonymous session so the app keeps working without
/// a forced login. The router redirect listens to `authStateProvider` and
/// will route the user back to `/scan` when the new snapshot fires.
Future<Result<void>> performLogout(WidgetRef ref) async {
  final auth = ref.read(authRepositoryProvider);
  final res = await auth.signOut();

  // Drop user-scoped state so a different account (or fresh anon) cannot see
  // the previous user's data flash on screen.
  ref.invalidate(profileProvider);
  ref.invalidate(billListProvider);

  // Re-establish a clean anonymous session, consistent with lazy-anon design.
  await ref.read(authRemoteDataSourceProvider).ensureSignedIn();

  return res;
}
