import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/providers.dart';
import '../../../domain/entities/bill.dart';
import '../../../domain/entities/item.dart';
import '../../../domain/entities/ocr_result.dart';
import '../../../domain/services/ocr_scale_normalizer.dart';
import '../../history/utils/bill_category.dart';
import '../../settings/providers/profile_notifier.dart';

part 'bill_review_notifier.freezed.dart';
part 'bill_review_notifier.g.dart';

/// Editable representation of a bill being reviewed before persistence.
///
/// Holds raw values only — TextEditingControllers stay in the widget layer
/// because they are part of the widget lifecycle, not domain state.
@freezed
abstract class BillReviewItem with _$BillReviewItem {
  const factory BillReviewItem({
    required String localId,
    required String name,
    required double price,
    required double qty,
  }) = _BillReviewItem;
}

@freezed
abstract class BillReviewState with _$BillReviewState {
  const factory BillReviewState({
    required String title,
    required List<BillReviewItem> items,
    required double tax,
    required double service,
    DateTime? receiptDate,
    double? detectedTotal,
    required double confidence,
    // ISO 4217 currency aktif saat review dimulai. Dipakai untuk safety net
    // mendeteksi bug parsing pemisah ribuan pada zero-decimal currencies.
    @Default('IDR') String currency,
    @Default(false) bool saving,
    // Bill category preset (server CHECK-enforced). Free for all presets;
    // custom tags are Plus-gated in the UI and normalized on save.
    @Default(BillCategory.lain) String category,
    @Default([]) List<String> tags,
  }) = _BillReviewState;

  const BillReviewState._();

  double get subtotal => items.fold<double>(0, (s, i) => s + i.price * i.qty);
  double get grandTotal => subtotal + tax + service;
  bool get hasMismatch {
    final d = detectedTotal;
    if (d == null) return false;
    return (grandTotal - d).abs() > AppConstants.billTotalMismatchTolerance;
  }

  /// Heuristic safety net: untuk zero-decimal currency (IDR/JPY/dll) setiap
  /// nilai harga seharusnya integer. Jika ada pecahan, kemungkinan besar
  /// pemisah ribuan ('.') ditafsirkan sebagai desimal oleh LLM. Tampilkan
  /// banner peringatan di review screen agar user verifikasi & koreksi.
  bool get suspectThousandsBug {
    if (!AppConstants.zeroDecimalCurrencies.contains(currency)) return false;
    bool isFractional(double v) => v != v.truncateToDouble();
    return items.any((i) => isFractional(i.price)) ||
        isFractional(tax) ||
        isFractional(service);
  }
}

/// Live-editable review state seeded from an [OcrResult]. Total recalculation
/// happens on every mutation so the sticky bottom bar stays in sync.
@riverpod
class BillReviewNotifier extends _$BillReviewNotifier {
  static const _uuid = Uuid();

  @override
  BillReviewState build(OcrResult ocr) {
    // Snapshot currency saat review dibuka — kalau user nanti ganti currency
    // di Settings, state ini tidak rebuild (review state spesifik per OCR
    // result), dan itu sengaja: angka di review berasal dari OCR yg dipanggil
    // dengan currency saat itu.
    final currency = ref.read(profileProvider).value?.defaultCurrency ?? 'USD';
    final normalizedOcr = OcrScaleNormalizer.normalizeZeroDecimalScale(
      ocr,
      currency,
    );
    return BillReviewState(
      title: normalizedOcr.merchant?.trim().isNotEmpty == true
          ? normalizedOcr.merchant!.trim()
          : 'Untitled bill',
      items: normalizedOcr.items
          .map(
            (e) => BillReviewItem(
              localId: _uuid.v4(),
              name: e.name,
              price: e.price,
              qty: e.qty,
            ),
          )
          .toList(growable: false),
      tax: normalizedOcr.detectedTax ?? 0,
      service: normalizedOcr.detectedService ?? 0,
      receiptDate: normalizedOcr.receiptDate,
      detectedTotal: normalizedOcr.detectedTotal,
      confidence: normalizedOcr.confidence,
      currency: currency,
    );
  }

  void setTitle(String value) => state = state.copyWith(title: value);
  void setCurrency(String value) => state = state.copyWith(currency: value);
  void setCategory(String value) =>
      state = state.copyWith(category: BillCategory.coerce(value));
  void setTags(List<String> tags) =>
      state = state.copyWith(tags: BillCategory.normalizeTags(tags));
  void setTax(double value) => state = state.copyWith(tax: value);
  void setService(double value) => state = state.copyWith(service: value);

  void updateItem(String localId, {String? name, double? price, double? qty}) {
    state = state.copyWith(
      items: [
        for (final it in state.items)
          if (it.localId == localId)
            it.copyWith(
              name: name ?? it.name,
              price: price ?? it.price,
              qty: qty ?? it.qty,
            )
          else
            it,
      ],
    );
  }

  void addItem() {
    state = state.copyWith(
      items: [
        ...state.items,
        BillReviewItem(localId: _uuid.v4(), name: '', price: 0, qty: 1),
      ],
    );
  }

  void removeItem(String localId) {
    state = state.copyWith(
      items: state.items.where((i) => i.localId != localId).toList(),
    );
  }

  /// Persists the bill + items via repository. Returns the saved bill id on
  /// success so the caller can navigate to the split screen, or `SaveError`
  /// with a human-readable message on failure.
  Future<SaveResult> save() async {
    // Re-entrancy guard: a second tap while a save is already in flight (e.g.
    // during the ensureSignedIn / createBill round-trips) would generate a
    // second bill id and persist a duplicate bill. Reject it silently.
    if (state.saving) return const SaveInProgress();

    if (state.title.trim().isEmpty) {
      return const SaveError(SaveErrorKind.titleRequired);
    }
    if (state.items.isEmpty) {
      return const SaveError(SaveErrorKind.itemsRequired);
    }
    for (final it in state.items) {
      if (it.name.trim().isEmpty || it.price < 0 || it.qty <= 0) {
        return const SaveError(SaveErrorKind.invalidItem);
      }
    }

    // Mark saving BEFORE the first await so a rapid second tap is caught by the
    // re-entrancy guard above instead of racing into a duplicate insert.
    state = state.copyWith(saving: true);

    final repo = ref.read(billRepositoryProvider);

    final authRes = await repo.ensureSignedIn();
    if (authRes is ResultFailure<void>) {
      state = state.copyWith(saving: false);
      AppLogger.error(
        'BillReviewNotifier.save: ensureSignedIn failed',
        authRes.failure,
      );
      return SaveError(SaveErrorKind.saveBillFailed, _msg(authRes.failure));
    }

    final billId = _uuid.v4();
    // Single timestamp for the whole save so downstream consumers (e.g. the
    // T+3/T+7 reminder schedule) use exactly the bill's creation time instead
    // of a second, drifting `DateTime.now()`.
    final createdAt = DateTime.now().toUtc();
    final bill = Bill(
      id: billId,
      title: state.title.trim(),
      totalAmount: state.grandTotal,
      currencyCode: state.currency,
      tax: state.tax,
      service: state.service,
      receiptDate: state.receiptDate,
      createdAt: createdAt,
      category: BillCategory.coerce(state.category),
      tags: BillCategory.normalizeTags(state.tags),
    );

    final billRes = await repo.createBill(bill);
    if (billRes is ResultFailure<Bill>) {
      state = state.copyWith(saving: false);
      AppLogger.error(
        'BillReviewNotifier.save: createBill failed',
        billRes.failure,
      );
      return SaveError(SaveErrorKind.saveBillFailed, _msg(billRes.failure));
    }

    final items = state.items
        .map(
          (e) => Item(
            id: _uuid.v4(),
            billId: billId,
            name: e.name.trim(),
            price: e.price,
            qty: e.qty,
          ),
        )
        .toList(growable: false);
    final itemsRes = await repo.upsertItems(items);
    if (itemsRes is ResultFailure<List<Item>>) {
      state = state.copyWith(saving: false);
      AppLogger.error(
        'BillReviewNotifier.save: upsertItems failed',
        itemsRes.failure,
      );
      return SaveError(SaveErrorKind.saveItemsFailed, _msg(itemsRes.failure));
    }

    state = state.copyWith(saving: false);
    return SaveSuccess(billId, createdAt);
  }

  static String _msg(Failure f) => f.toString();
}

sealed class SaveResult {
  const SaveResult();
}

class SaveSuccess extends SaveResult {
  const SaveSuccess(this.billId, this.createdAt);
  final String billId;

  /// The bill's creation timestamp — downstream consumers must reuse this
  /// instead of sampling their own clock (avoids save-latency/skew drift).
  final DateTime createdAt;
}

/// Returned when [BillReviewNotifier.save] is invoked while a previous save is
/// still in flight. The caller should ignore it (no error surfaced to the user).
class SaveInProgress extends SaveResult {
  const SaveInProgress();
}

class SaveError extends SaveResult {
  const SaveError(this.kind, [this.message]);
  final SaveErrorKind kind;
  final String? message;
}

enum SaveErrorKind {
  titleRequired,
  itemsRequired,
  invalidItem,
  saveBillFailed,
  saveItemsFailed,
}
