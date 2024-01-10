import 'package:json_annotation/json_annotation.dart';
import 'package:octobase_flutter/models/meta.dart';

part 'collection.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class Collection<T> {
  List<T>? data;

  Meta? meta;

  Collection({this.data, this.meta});

  factory Collection.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$CollectionFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$CollectionToJson(this, toJsonT);
}
