import 'package:freezed_annotation/freezed_annotation.dart';

part 'geography.freezed.dart';
part 'geography.g.dart';

@freezed
class Geography with _$Geography {
  const factory Geography({required int id, required String name}) = _Geography;

  factory Geography.fromJson(Map<String, dynamic> json) =>
      _$GeographyFromJson(json);
}
