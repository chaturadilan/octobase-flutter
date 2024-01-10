// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meta.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Meta _$MetaFromJson(Map<String, dynamic> json) => Meta(
      perPage: json['per_page'] as int?,
      total: json['total'] as int?,
      page: json['page'] as int?,
    );

Map<String, dynamic> _$MetaToJson(Meta instance) => <String, dynamic>{
      'per_page': instance.perPage,
      'total': instance.total,
      'page': instance.page,
    };
