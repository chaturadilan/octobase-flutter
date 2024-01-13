import 'package:json_annotation/json_annotation.dart';

part 'user_info.g.dart';

@JsonSerializable()
class UserInfo {
  int? id;
  @JsonKey(name: 'first_name')
  String? firstName;
  @JsonKey(name: 'last_name')
  String? lastName;
  String? email;
  String? username;
  @JsonKey(name: 'is_activated')
  bool? isActivated;
  List<String>? groups;
  dynamic avatar;
  @JsonKey(name: 'is_new')
  bool? isNew;
  String? token;

  UserInfo({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.username,
    this.isActivated,
    this.groups,
    this.avatar,
    this.isNew,
    this.token,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return _$UserInfoFromJson(json);
  }

  Map<String, dynamic> toJson() => _$UserInfoToJson(this);
}
