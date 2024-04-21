// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'octobase_error.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OctobaseError _$OctobaseErrorFromJson(Map<String, dynamic> json) =>
    OctobaseError(
      message: json['message'] as String?,
      code: json['code'] as int?,
    );

Map<String, dynamic> _$OctobaseErrorToJson(OctobaseError instance) =>
    <String, dynamic>{
      'message': instance.message,
      'code': instance.code,
    };
