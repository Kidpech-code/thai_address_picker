// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sub_district.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SubDistrict {
  int get id => throw _privateConstructorUsedError;
  String get zipCode =>
      throw _privateConstructorUsedError; // String for safety (leading zeros)
  String get nameTh => throw _privateConstructorUsedError;
  String get nameEn => throw _privateConstructorUsedError;
  int get districtId => throw _privateConstructorUsedError;
  double? get lat => throw _privateConstructorUsedError;
  double? get long => throw _privateConstructorUsedError;

  /// Create a copy of SubDistrict
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubDistrictCopyWith<SubDistrict> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubDistrictCopyWith<$Res> {
  factory $SubDistrictCopyWith(
    SubDistrict value,
    $Res Function(SubDistrict) then,
  ) = _$SubDistrictCopyWithImpl<$Res, SubDistrict>;
  @useResult
  $Res call({
    int id,
    String zipCode,
    String nameTh,
    String nameEn,
    int districtId,
    double? lat,
    double? long,
  });
}

/// @nodoc
class _$SubDistrictCopyWithImpl<$Res, $Val extends SubDistrict>
    implements $SubDistrictCopyWith<$Res> {
  _$SubDistrictCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubDistrict
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? zipCode = null,
    Object? nameTh = null,
    Object? nameEn = null,
    Object? districtId = null,
    Object? lat = freezed,
    Object? long = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            zipCode: null == zipCode
                ? _value.zipCode
                : zipCode // ignore: cast_nullable_to_non_nullable
                      as String,
            nameTh: null == nameTh
                ? _value.nameTh
                : nameTh // ignore: cast_nullable_to_non_nullable
                      as String,
            nameEn: null == nameEn
                ? _value.nameEn
                : nameEn // ignore: cast_nullable_to_non_nullable
                      as String,
            districtId: null == districtId
                ? _value.districtId
                : districtId // ignore: cast_nullable_to_non_nullable
                      as int,
            lat: freezed == lat
                ? _value.lat
                : lat // ignore: cast_nullable_to_non_nullable
                      as double?,
            long: freezed == long
                ? _value.long
                : long // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubDistrictImplCopyWith<$Res>
    implements $SubDistrictCopyWith<$Res> {
  factory _$$SubDistrictImplCopyWith(
    _$SubDistrictImpl value,
    $Res Function(_$SubDistrictImpl) then,
  ) = __$$SubDistrictImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String zipCode,
    String nameTh,
    String nameEn,
    int districtId,
    double? lat,
    double? long,
  });
}

/// @nodoc
class __$$SubDistrictImplCopyWithImpl<$Res>
    extends _$SubDistrictCopyWithImpl<$Res, _$SubDistrictImpl>
    implements _$$SubDistrictImplCopyWith<$Res> {
  __$$SubDistrictImplCopyWithImpl(
    _$SubDistrictImpl _value,
    $Res Function(_$SubDistrictImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubDistrict
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? zipCode = null,
    Object? nameTh = null,
    Object? nameEn = null,
    Object? districtId = null,
    Object? lat = freezed,
    Object? long = freezed,
  }) {
    return _then(
      _$SubDistrictImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        zipCode: null == zipCode
            ? _value.zipCode
            : zipCode // ignore: cast_nullable_to_non_nullable
                  as String,
        nameTh: null == nameTh
            ? _value.nameTh
            : nameTh // ignore: cast_nullable_to_non_nullable
                  as String,
        nameEn: null == nameEn
            ? _value.nameEn
            : nameEn // ignore: cast_nullable_to_non_nullable
                  as String,
        districtId: null == districtId
            ? _value.districtId
            : districtId // ignore: cast_nullable_to_non_nullable
                  as int,
        lat: freezed == lat
            ? _value.lat
            : lat // ignore: cast_nullable_to_non_nullable
                  as double?,
        long: freezed == long
            ? _value.long
            : long // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc

class _$SubDistrictImpl implements _SubDistrict {
  const _$SubDistrictImpl({
    required this.id,
    required this.zipCode,
    required this.nameTh,
    required this.nameEn,
    required this.districtId,
    required this.lat,
    required this.long,
  });

  @override
  final int id;
  @override
  final String zipCode;
  // String for safety (leading zeros)
  @override
  final String nameTh;
  @override
  final String nameEn;
  @override
  final int districtId;
  @override
  final double? lat;
  @override
  final double? long;

  @override
  String toString() {
    return 'SubDistrict(id: $id, zipCode: $zipCode, nameTh: $nameTh, nameEn: $nameEn, districtId: $districtId, lat: $lat, long: $long)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubDistrictImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.zipCode, zipCode) || other.zipCode == zipCode) &&
            (identical(other.nameTh, nameTh) || other.nameTh == nameTh) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.districtId, districtId) ||
                other.districtId == districtId) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.long, long) || other.long == long));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    zipCode,
    nameTh,
    nameEn,
    districtId,
    lat,
    long,
  );

  /// Create a copy of SubDistrict
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubDistrictImplCopyWith<_$SubDistrictImpl> get copyWith =>
      __$$SubDistrictImplCopyWithImpl<_$SubDistrictImpl>(this, _$identity);
}

abstract class _SubDistrict implements SubDistrict {
  const factory _SubDistrict({
    required final int id,
    required final String zipCode,
    required final String nameTh,
    required final String nameEn,
    required final int districtId,
    required final double? lat,
    required final double? long,
  }) = _$SubDistrictImpl;

  @override
  int get id;
  @override
  String get zipCode; // String for safety (leading zeros)
  @override
  String get nameTh;
  @override
  String get nameEn;
  @override
  int get districtId;
  @override
  double? get lat;
  @override
  double? get long;

  /// Create a copy of SubDistrict
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubDistrictImplCopyWith<_$SubDistrictImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
