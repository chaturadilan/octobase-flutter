// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'octobase_error.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OctobaseError _$OctobaseErrorFromJson(Map<String, dynamic> json) =>
    OctobaseError(
      error: json['error'] as String?,
      code: json['code'] as int?,
    );

Map<String, dynamic> _$OctobaseErrorToJson(OctobaseError instance) =>
    <String, dynamic>{
      'error': instance.error,
      'code': instance.code,
    };
