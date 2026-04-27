import 'package:freezed_annotation/freezed_annotation.dart';

part 'bill.freezed.dart';

@freezed
abstract class Bill with _$Bill {
  const factory Bill({
    required String id,
    required String title,
    required double totalAmount,
    @Default(0) double tax,
    @Default(0) double service,
    @Default(false) bool isSettled,
    required DateTime createdAt,
  }) = _Bill;
}
