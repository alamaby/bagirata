import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/error/result.dart';
import '../../../core/router/routes.dart';
import '../../../data/providers.dart';
import '../../../domain/entities/bill.dart';
import '../../../domain/entities/item.dart';
import '../../../domain/entities/ocr_result.dart';
import '../../shared/widgets/app_scaffold.dart';

/// Mandatory verification gate between OCR success and DB persistence.
///
/// Why a manual review step: LLMs return null tax/service when the receipt
/// hides them in a footer, and qty can be fractional (Bandeng Juwana's 0.58 kg).
/// Persisting blindly risks bills with wrong totals — so the user must confirm
/// numbers and fill the gaps before save.
class BillReviewScreen extends ConsumerStatefulWidget {
  const BillReviewScreen({super.key, required this.ocr});

  final OcrResult ocr;

  @override
  ConsumerState<BillReviewScreen> createState() => _BillReviewScreenState();
}

class _BillReviewScreenState extends ConsumerState<BillReviewScreen> {
  static const _uuid = Uuid();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _taxCtrl;
  late final TextEditingController _serviceCtrl;
  late final List<_EditableItem> _items;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final ocr = widget.ocr;
    _titleCtrl = TextEditingController(
      text: ocr.merchant?.trim().isNotEmpty == true
          ? ocr.merchant!.trim()
          : 'Untitled bill',
    );
    _taxCtrl = TextEditingController(
      text: ocr.detectedTax != null ? _fmtNum(ocr.detectedTax!) : '',
    );
    _serviceCtrl = TextEditingController(
      text: ocr.detectedService != null ? _fmtNum(ocr.detectedService!) : '',
    );
    _items = ocr.items
        .map((e) => _EditableItem.fromOcr(e))
        .toList(growable: true);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _taxCtrl.dispose();
    _serviceCtrl.dispose();
    for (final i in _items) {
      i.dispose();
    }
    super.dispose();
  }

  double get _subtotal =>
      _items.fold<double>(0, (s, i) => s + i.price * i.qty);

  double get _tax => double.tryParse(_taxCtrl.text.trim()) ?? 0;

  double get _service => double.tryParse(_serviceCtrl.text.trim()) ?? 0;

  double get _computedTotal => _subtotal + _tax + _service;

  bool get _hasMismatch {
    final detected = widget.ocr.detectedTotal;
    if (detected == null) return false;
    return (_computedTotal - detected).abs() >
        AppConstants.billTotalMismatchTolerance;
  }

  void _addItem() {
    setState(() => _items.add(_EditableItem.empty()));
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index).dispose();
    });
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      _toast('Judul tidak boleh kosong');
      return;
    }
    if (_items.isEmpty) {
      _toast('Tambahkan minimal satu item');
      return;
    }
    for (final it in _items) {
      if (it.name.trim().isEmpty || it.price <= 0 || it.qty <= 0) {
        _toast('Periksa nama, harga, dan qty setiap item');
        return;
      }
    }

    setState(() => _saving = true);
    final repo = ref.read(billRepositoryProvider);
    final billId = _uuid.v4();
    final bill = Bill(
      id: billId,
      title: title,
      totalAmount: _computedTotal,
      tax: _tax,
      service: _service,
      createdAt: DateTime.now().toUtc(),
    );
    final billRes = await repo.createBill(bill);
    if (!mounted) return;
    if (billRes is ResultFailure<Bill>) {
      setState(() => _saving = false);
      _toast('Gagal simpan bill: ${billRes.failure}');
      return;
    }

    final items = _items
        .map((e) => Item(
              id: _uuid.v4(),
              billId: billId,
              name: e.name.trim(),
              price: e.price,
              qty: e.qty,
            ))
        .toList(growable: false);
    final itemsRes = await repo.upsertItems(items);
    if (!mounted) return;
    if (itemsRes is ResultFailure<List<Item>>) {
      setState(() => _saving = false);
      _toast('Bill tersimpan tapi item gagal: ${itemsRes.failure}');
      return;
    }

    if (!mounted) return;
    setState(() => _saving = false);
    context.goNamed(Routes.billListName);
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency();
    final lowConfidence =
        widget.ocr.confidence < AppConstants.ocrLowConfidenceThreshold;

    return AppScaffold(
      title: 'Review bill',
      body: AbsorbPointer(
        absorbing: _saving,
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Judul bill',
                border: OutlineInputBorder(),
              ),
            ),
            if (lowConfidence) ...[
              SizedBox(height: 12.h),
              _ConfidenceChip(confidence: widget.ocr.confidence),
            ],
            SizedBox(height: 16.h),
            Text('Items', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 8.h),
            ..._items.asMap().entries.map(
                  (entry) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: _ItemRow(
                      item: entry.value,
                      onRemove: () => _removeItem(entry.key),
                      onChanged: () => setState(() {}),
                    ),
                  ),
                ),
            OutlinedButton.icon(
              onPressed: _addItem,
              icon: const Icon(Icons.add),
              label: const Text('Tambah item'),
            ),
            SizedBox(height: 16.h),
            _SummaryRow(label: 'Subtotal', value: currency.format(_subtotal)),
            SizedBox(height: 8.h),
            TextField(
              controller: _taxCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Pajak',
                hintText: widget.ocr.detectedTax == null
                    ? 'Kosongkan jika tidak ada pajak'
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _serviceCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Service charge',
                hintText: widget.ocr.detectedService == null
                    ? 'Kosongkan jika tidak ada service'
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12.h),
            if (_hasMismatch)
              _MismatchBanner(
                computed: _computedTotal,
                detected: widget.ocr.detectedTotal!,
                currency: currency,
              ),
            SizedBox(height: 12.h),
            _SummaryRow(
              label: 'Total',
              value: currency.format(_computedTotal),
              emphasised: true,
            ),
            SizedBox(height: 24.h),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child:
                          const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_saving ? 'Menyimpan…' : 'Simpan bill'),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmtNum(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
}

class _EditableItem {
  _EditableItem({
    required this.nameCtrl,
    required this.priceCtrl,
    required this.qtyCtrl,
  });

  factory _EditableItem.fromOcr(OcrLineItem o) => _EditableItem(
        nameCtrl: TextEditingController(text: o.name),
        priceCtrl: TextEditingController(
          text: _BillReviewScreenState._fmtNum(o.price),
        ),
        qtyCtrl: TextEditingController(
          text: _BillReviewScreenState._fmtNum(o.qty),
        ),
      );

  factory _EditableItem.empty() => _EditableItem(
        nameCtrl: TextEditingController(),
        priceCtrl: TextEditingController(text: '0'),
        qtyCtrl: TextEditingController(text: '1'),
      );

  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController qtyCtrl;

  String get name => nameCtrl.text;
  double get price => double.tryParse(priceCtrl.text.trim()) ?? 0;
  double get qty => double.tryParse(qtyCtrl.text.trim()) ?? 0;

  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    qtyCtrl.dispose();
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.item,
    required this.onRemove,
    required this.onChanged,
  });

  final _EditableItem item;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          children: [
            TextField(
              controller: item.nameCtrl,
              onChanged: (_) => onChanged(),
              decoration: const InputDecoration(
                labelText: 'Nama',
                isDense: true,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: item.qtyCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    onChanged: (_) => onChanged(),
                    decoration: const InputDecoration(
                      labelText: 'Qty',
                      isDense: true,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: item.priceCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    onChanged: (_) => onChanged(),
                    decoration: const InputDecoration(
                      labelText: 'Harga / unit',
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onRemove,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasised = false,
  });

  final String label;
  final String value;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final style = emphasised
        ? Theme.of(context).textTheme.titleLarge
        : Theme.of(context).textTheme.bodyLarge;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: style), Text(value, style: style)],
    );
  }
}

class _MismatchBanner extends StatelessWidget {
  const _MismatchBanner({
    required this.computed,
    required this.detected,
    required this.currency,
  });

  final double computed;
  final double detected;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: scheme.onErrorContainer),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Total dihitung ${currency.format(computed)} berbeda dari struk '
              '(${currency.format(detected)}). Periksa lagi.',
              style: TextStyle(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfidenceChip extends StatelessWidget {
  const _ConfidenceChip({required this.confidence});
  final double confidence;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.info_outline, size: 18),
      label: Text(
        'AI kurang yakin (${(confidence * 100).toStringAsFixed(0)}%) — '
        'periksa angka secara teliti.',
        style: TextStyle(fontSize: 12.sp),
      ),
    );
  }
}
