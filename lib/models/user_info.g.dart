// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) => UserInfo(
      id: json['id'] as int?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      username: json['username'] as String?,
      isActivated: json['is_activated'] as bool?,
      groups:
          (json['groups'] as List<dynamic>?)?.map((e) => e as String).toList(),
      avatar: json['avatar'],
      isNew: json['is_new'] as bool?,
      token: json['token'] as String?,
    );

Map<String, dynamic> _$UserInfoToJson(UserInfo instance) => <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'email': instance.email,
      'username': instance.username,
      'is_activated': instance.isActivated,
      'groups': instance.groups,
      'avatar': instance.avatar,
      'is_new': instance.isNew,
      'token': instance.token,
    };
