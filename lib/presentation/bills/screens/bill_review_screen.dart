import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/format/app_format.dart';
import '../../../core/router/routes.dart';
import '../../../domain/entities/ocr_result.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../providers/bill_review_notifier.dart';

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
  late final TextEditingController _titleCtrl;
  late final TextEditingController _taxCtrl;
  late final TextEditingController _serviceCtrl;
  final Map<String, _ItemControllers> _itemCtrls = {};

  BillReviewNotifier get _notifier =>
      ref.read(billReviewFamily(widget.ocr).notifier);

  @override
  void initState() {
    super.initState();
    final initial = ref.read(billReviewFamily(widget.ocr));
    _titleCtrl = TextEditingController(text: initial.title);
    _taxCtrl = TextEditingController(
      text: initial.tax > 0 ? _fmtNum(initial.tax) : '',
    );
    _serviceCtrl = TextEditingController(
      text: initial.service > 0 ? _fmtNum(initial.service) : '',
    );
    for (final it in initial.items) {
      _itemCtrls[it.localId] = _ItemControllers.fromItem(it);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _taxCtrl.dispose();
    _serviceCtrl.dispose();
    for (final c in _itemCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncItemControllers(BillReviewState state) {
    final nextIds = state.items.map((e) => e.localId).toSet();
    _itemCtrls.removeWhere((id, ctrls) {
      if (nextIds.contains(id)) return false;
      ctrls.dispose();
      return true;
    });
    for (final it in state.items) {
      _itemCtrls.putIfAbsent(it.localId, () => _ItemControllers.fromItem(it));
    }
  }

  Future<void> _onSave() async {
    final result = await _notifier.save();
    if (!mounted) return;
    switch (result) {
      case SaveError(:final message):
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      case SaveSuccess(:final billId):
        context.goNamed(
          Routes.billSplitName,
          pathParameters: {'billId': billId},
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(billReviewFamily(widget.ocr));
    _syncItemControllers(state);

    final currency = AppFormat.currency();
    final lowConfidence =
        state.confidence < AppConstants.ocrLowConfidenceThreshold;

    return AppScaffold(
      title: 'Review bill',
      body: AbsorbPointer(
        absorbing: state.saving,
        child: Column(
          children: [
            _Header(
              titleCtrl: _titleCtrl,
              receiptDate: state.receiptDate,
              lowConfidence: lowConfidence,
              confidence: state.confidence,
              onTitleChanged: _notifier.setTitle,
            ),
            if (state.hasMismatch && state.detectedTotal != null)
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                child: _MismatchBanner(
                  computed: state.grandTotal,
                  detected: state.detectedTotal!,
                  currency: currency,
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(bottom: 8.h),
                itemCount: state.items.length + 1,
                itemBuilder: (context, index) {
                  if (index == state.items.length) {
                    return Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
                      child: OutlinedButton.icon(
                        onPressed: _notifier.addItem,
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah item'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size.fromHeight(44.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    );
                  }
                  final item = state.items[index];
                  final ctrls = _itemCtrls[item.localId]!;
                  return Dismissible(
                    key: ValueKey(item.localId),
                    direction: DismissDirection.endToStart,
                    background: _SwipeBackground(),
                    confirmDismiss: (_) async {
                      final hasContent = item.name.trim().isNotEmpty ||
                          item.price > 0;
                      if (!hasContent) return true;
                      return await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Hapus item?'),
                              content: Text(
                                'Item "${item.name.isEmpty ? 'tanpa nama' : item.name}" akan dihapus.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Batal'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Hapus'),
                                ),
                              ],
                            ),
                          ) ??
                          false;
                    },
                    onDismissed: (_) => _notifier.removeItem(item.localId),
                    child: _ItemCard(
                      item: item,
                      controllers: ctrls,
                      onNameChanged: (v) =>
                          _notifier.updateItem(item.localId, name: v),
                      onPriceChanged: (v) => _notifier.updateItem(
                        item.localId,
                        price: double.tryParse(v.trim()) ?? 0,
                      ),
                      onQtyChanged: (v) => _notifier.updateItem(
                        item.localId,
                        qty: double.tryParse(v.trim()) ?? 0,
                      ),
                    ),
                  );
                },
              ),
            ),
            _StickyBottom(
              state: state,
              currency: currency,
              taxCtrl: _taxCtrl,
              serviceCtrl: _serviceCtrl,
              onTaxChanged: (v) =>
                  _notifier.setTax(double.tryParse(v.trim()) ?? 0),
              onServiceChanged: (v) =>
                  _notifier.setService(double.tryParse(v.trim()) ?? 0),
              onSave: _onSave,
            ),
          ],
        ),
      ),
    );
  }
}

String _fmtNum(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

class _ItemControllers {
  _ItemControllers({
    required this.name,
    required this.price,
    required this.qty,
  }) {
    priceFocus.addListener(() => _selectAll(price, priceFocus));
    qtyFocus.addListener(() => _selectAll(qty, qtyFocus));
  }

  factory _ItemControllers.fromItem(BillReviewItem it) => _ItemControllers(
        name: TextEditingController(text: it.name),
        price: TextEditingController(text: _fmtNum(it.price)),
        qty: TextEditingController(text: _fmtNum(it.qty)),
      );

  final TextEditingController name;
  final TextEditingController price;
  final TextEditingController qty;
  final FocusNode priceFocus = FocusNode();
  final FocusNode qtyFocus = FocusNode();

  static void _selectAll(TextEditingController c, FocusNode node) {
    if (node.hasFocus && c.text.isNotEmpty) {
      c.selection =
          TextSelection(baseOffset: 0, extentOffset: c.text.length);
    }
  }

  void dispose() {
    name.dispose();
    price.dispose();
    qty.dispose();
    priceFocus.dispose();
    qtyFocus.dispose();
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.titleCtrl,
    required this.receiptDate,
    required this.lowConfidence,
    required this.confidence,
    required this.onTitleChanged,
  });

  final TextEditingController titleCtrl;
  final DateTime? receiptDate;
  final bool lowConfidence;
  final double confidence;
  final ValueChanged<String> onTitleChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storefront, size: 22.r, color: scheme.primary),
              SizedBox(width: 10.w),
              Expanded(
                child: TextField(
                  controller: titleCtrl,
                  onChanged: onTitleChanged,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'Nama merchant',
                    hintStyle: TextStyle(
                      fontSize: 20.sp,
                      color: scheme.outline,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (receiptDate != null) ...[
            SizedBox(height: 6.h),
            Padding(
              padding: EdgeInsets.only(left: 32.w),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 14.r, color: scheme.outline),
                  SizedBox(width: 6.w),
                  Text(
                    AppFormat.longDate().format(receiptDate!),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: scheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (lowConfidence) ...[
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: scheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline,
                      size: 14.r, color: scheme.onTertiaryContainer),
                  SizedBox(width: 6.w),
                  Flexible(
                    child: Text(
                      'AI kurang yakin (${(confidence * 100).toStringAsFixed(0)}%) — periksa angka.',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: scheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.item,
    required this.controllers,
    required this.onNameChanged,
    required this.onPriceChanged,
    required this.onQtyChanged,
  });

  final BillReviewItem item;
  final _ItemControllers controllers;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onPriceChanged;
  final ValueChanged<String> onQtyChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controllers.name,
              onChanged: onNameChanged,
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
              decoration: const InputDecoration(
                hintText: 'Nama item',
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: controllers.qty,
                    focusNode: controllers.qtyFocus,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    onChanged: onQtyChanged,
                    decoration: InputDecoration(
                      labelText: 'Qty',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: controllers.price,
                    focusNode: controllers.priceFocus,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    onChanged: onPriceChanged,
                    decoration: InputDecoration(
                      labelText: 'Harga / unit',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Icon(
        Icons.delete_sweep,
        color: Theme.of(context).colorScheme.onError,
        size: 24.r,
      ),
    );
  }
}

class _StickyBottom extends StatelessWidget {
  const _StickyBottom({
    required this.state,
    required this.currency,
    required this.taxCtrl,
    required this.serviceCtrl,
    required this.onTaxChanged,
    required this.onServiceChanged,
    required this.onSave,
  });

  final BillReviewState state;
  final NumberFormat currency;
  final TextEditingController taxCtrl;
  final TextEditingController serviceCtrl;
  final ValueChanged<String> onTaxChanged;
  final ValueChanged<String> onServiceChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final totalColor =
        state.hasMismatch ? Colors.orange.shade700 : scheme.onSurface;

    return Material(
      elevation: 8,
      color: scheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: EdgeInsets.only(bottom: 8.h),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      Text(
                        currency.format(state.subtotal),
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ],
                  ),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: taxCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]'),
                              ),
                            ],
                            onChanged: onTaxChanged,
                            decoration: InputDecoration(
                              labelText: 'Pajak',
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: TextField(
                            controller: serviceCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]'),
                              ),
                            ],
                            onChanged: onServiceChanged,
                            decoration: InputDecoration(
                              labelText: 'Service',
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: totalColor,
                    ),
                  ),
                  Text(
                    currency.format(state.grandTotal),
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: totalColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              _SaveButton(saving: state.saving, onTap: onSave),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.saving, required this.onTap});

  final bool saving;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary,
              Color.alphaBlend(
                Colors.black.withValues(alpha: 0.15),
                scheme.primary,
              ),
            ],
          ),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.30),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14.r),
            onTap: saving ? null : onTap,
            child: Center(
              child: saving
                  ? SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation(scheme.onPrimary),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle,
                            color: scheme.onPrimary, size: 20.r),
                        SizedBox(width: 8.w),
                        Text(
                          'Simpan Bill',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: scheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
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
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: Colors.orange.shade700, size: 20.r),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Total ${currency.format(computed)} berbeda dari struk '
              '(${currency.format(detected)}). Periksa lagi.',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.orange.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
