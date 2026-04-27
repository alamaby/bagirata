import 'package:freezed_annotation/freezed_annotation.dart';

part 'item.freezed.dart';

@freezed
abstract class Item with _$Item {
  const Item._();

  const factory Item({
    required String id,
    required String billId,
    required String name,
    required double price,
    @Default(1) int qty,
  }) = _Item;

  double get subtotal => price * qty;
}
