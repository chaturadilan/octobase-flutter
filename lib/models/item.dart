import 'package:json_annotation/json_annotation.dart';

part 'item.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class Item<T> {
  T? data;

  Item({this.data});

  factory Item.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ItemFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$ItemToJson(this, toJsonT);
}
