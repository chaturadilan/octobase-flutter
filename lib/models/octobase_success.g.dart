// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'octobase_success.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OctobaseSuccess _$OctobaseSuccessFromJson(Map<String, dynamic> json) =>
    OctobaseSuccess(
      success: json['success'] as String?,
      code: (json['code'] as num?)?.toInt(),
    );

Map<String, dynamic> _$OctobaseSuccessToJson(OctobaseSuccess instance) =>
    <String, dynamic>{
      'success': instance.success,
      'code': instance.code,
    };
