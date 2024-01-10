import 'package:json_annotation/json_annotation.dart';

part 'octobase_success.g.dart';

@JsonSerializable()
class OctobaseSuccess {
  String? success;
  int? code;

  OctobaseSuccess({this.success, this.code});

  factory OctobaseSuccess.fromJson(Map<String, dynamic> json) {
    return _$OctobaseSuccessFromJson(json);
  }

  Map<String, dynamic> toJson() => _$OctobaseSuccessToJson(this);
}
