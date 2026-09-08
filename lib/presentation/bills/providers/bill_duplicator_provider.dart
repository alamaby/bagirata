import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers.dart';
import '../../../domain/services/bill_duplicator.dart';

/// M4/F12 one-tap bill duplication, backed by [BillDuplicator] over the
/// shared repository. Plain provider (no codegen): no async state of its
/// own — callers await `duplicate()` and navigate on success.
final billDuplicatorProvider = Provider<BillDuplicator>(
  (ref) => BillDuplicator(ref.watch(billRepositoryProvider)),
);
