import 'package:json_annotation/json_annotation.dart';

part 'octobase_error.g.dart';

@JsonSerializable()
class OctobaseError {
  String? message;
  int? code;

  OctobaseError({this.message, this.code});

  factory OctobaseError.fromJson(Map<String, dynamic> json) {
    return _$OctobaseErrorFromJson(json);
  }

  Map<String, dynamic> toJson() => _$OctobaseErrorToJson(this);
}
