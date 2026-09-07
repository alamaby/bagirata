// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_bill_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HistoryBillDto _$HistoryBillDtoFromJson(Map<String, dynamic> json) =>
    _HistoryBillDto(
      id: json['id'] as String,
      title: json['title'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      currencyCode: json['currency_code'] as String? ?? 'IDR',
      tax: (json['tax_amount'] as num?)?.toDouble() ?? 0,
      service: (json['service_charge'] as num?)?.toDouble() ?? 0,
      isSettled: json['is_settled'] as bool? ?? false,
      receiptDate: json['receipt_date'] == null
          ? null
          : DateTime.parse(json['receipt_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      category: json['category'] as String? ?? 'lain',
      tags:
          (json['bill_tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      participantCount: (json['participant_count'] as num).toInt(),
      paidParticipantCount: (json['paid_participant_count'] as num).toInt(),
      paymentStatus: json['payment_status'] as String,
    );

Map<String, dynamic> _$HistoryBillDtoToJson(_HistoryBillDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'total_amount': instance.totalAmount,
      'currency_code': instance.currencyCode,
      'tax_amount': instance.tax,
      'service_charge': instance.service,
      'is_settled': instance.isSettled,
      'receipt_date': ?instance.receiptDate?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'category': instance.category,
      'bill_tags': instance.tags,
      'participant_count': instance.participantCount,
      'paid_participant_count': instance.paidParticipantCount,
      'payment_status': instance.paymentStatus,
    };
