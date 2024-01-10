import 'package:json_annotation/json_annotation.dart';

part 'meta.g.dart';

@JsonSerializable()
class Meta {
  @JsonKey(name: 'per_page')
  int? perPage;
  int? total;
  int? page;

  Meta({this.perPage, this.total, this.page});

  factory Meta.fromJson(Map<String, dynamic> json) {
    return _$MetaFromJson(json);
  }

  Map<String, dynamic> toJson() => _$MetaToJson(this);
}
