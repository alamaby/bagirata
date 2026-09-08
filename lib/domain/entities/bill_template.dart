import 'package:freezed_annotation/freezed_annotation.dart';

part 'bill_template.freezed.dart';
part 'bill_template.g.dart';

/// M4/F12 bill template: a versioned snapshot of one bill's reusable shape
/// (title, currency, tax/service, category, items + shares with weights).
/// Server validates the snapshot strictly on instantiate; the client treats
/// it as opaque and never constructs one by hand.
@freezed
abstract class BillTemplate with _$BillTemplate {
  const factory BillTemplate({
    required String id,
    required String name,
    @JsonKey(name: 'use_count') @Default(0) int useCount,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _BillTemplate;

  factory BillTemplate.fromJson(Map<String, dynamic> json) =>
      _$BillTemplateFromJson(json);
}
