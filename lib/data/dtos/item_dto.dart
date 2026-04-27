import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/item.dart';

part 'item_dto.freezed.dart';
part 'item_dto.g.dart';

@freezed
abstract class ItemDto with _$ItemDto {
  const ItemDto._();

  const factory ItemDto({
    required String id,
    @JsonKey(name: 'bill_id') required String billId,
    required String name,
    required double price,
    @Default(1) int qty,
  }) = _ItemDto;

  factory ItemDto.fromJson(Map<String, dynamic> json) => _$ItemDtoFromJson(json);

  factory ItemDto.fromEntity(Item i) => ItemDto(
        id: i.id,
        billId: i.billId,
        name: i.name,
        price: i.price,
        qty: i.qty,
      );

  Item toEntity() => Item(id: id, billId: billId, name: name, price: price, qty: qty);
}
