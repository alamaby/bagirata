import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/format/currency_formatter.dart';
import '../../../l10n/generated/app_l10n.dart';

Future<String?> showCurrencyPickerSheet(BuildContext context, String current) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => _CurrencyPickerSheet(current: current),
  );
}

class _CurrencyPickerSheet extends StatefulWidget {
  const _CurrencyPickerSheet({required this.current});
  final String current;

  @override
  State<_CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<_CurrencyPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final definitions = CurrencyFormatter.definitions;
    final filtered = definitions.where(
      (d) => CurrencyFormatter.matchesQuery(d, _query),
    ).toList(growable: false);
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, viewInsets),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 8.h),
              child: Text(
                l10n.currencyLabel,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: l10n.cancelAction,
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close),
                        ),
                  hintText: l10n.currencySearchHint,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            SizedBox(height: 8.h),
            Flexible(
              child: filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Text(
                          l10n.currencySearchEmpty,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final d = filtered[index];
                        return RadioListTile<String>(
                          value: d.code,
                          groupValue: widget.current,
                          onChanged: (v) => Navigator.of(context).pop(v),
                          title: Text(
                            d.displayName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}