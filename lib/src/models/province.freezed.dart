// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'province.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Province {
  int get id => throw _privateConstructorUsedError;
  String get nameTh => throw _privateConstructorUsedError;
  String get nameEn => throw _privateConstructorUsedError;
  int get geographyId => throw _privateConstructorUsedError;

  /// Create a copy of Province
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProvinceCopyWith<Province> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProvinceCopyWith<$Res> {
  factory $ProvinceCopyWith(Province value, $Res Function(Province) then) =
      _$ProvinceCopyWithImpl<$Res, Province>;
  @useResult
  $Res call({int id, String nameTh, String nameEn, int geographyId});
}

/// @nodoc
class _$ProvinceCopyWithImpl<$Res, $Val extends Province>
    implements $ProvinceCopyWith<$Res> {
  _$ProvinceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Province
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameTh = null,
    Object? nameEn = null,
    Object? geographyId = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            nameTh: null == nameTh
                ? _value.nameTh
                : nameTh // ignore: cast_nullable_to_non_nullable
                      as String,
            nameEn: null == nameEn
                ? _value.nameEn
                : nameEn // ignore: cast_nullable_to_non_nullable
                      as String,
            geographyId: null == geographyId
                ? _value.geographyId
                : geographyId // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProvinceImplCopyWith<$Res>
    implements $ProvinceCopyWith<$Res> {
  factory _$$ProvinceImplCopyWith(
    _$ProvinceImpl value,
    $Res Function(_$ProvinceImpl) then,
  ) = __$$ProvinceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String nameTh, String nameEn, int geographyId});
}

/// @nodoc
class __$$ProvinceImplCopyWithImpl<$Res>
    extends _$ProvinceCopyWithImpl<$Res, _$ProvinceImpl>
    implements _$$ProvinceImplCopyWith<$Res> {
  __$$ProvinceImplCopyWithImpl(
    _$ProvinceImpl _value,
    $Res Function(_$ProvinceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Province
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameTh = null,
    Object? nameEn = null,
    Object? geographyId = null,
  }) {
    return _then(
      _$ProvinceImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        nameTh: null == nameTh
            ? _value.nameTh
            : nameTh // ignore: cast_nullable_to_non_nullable
                  as String,
        nameEn: null == nameEn
            ? _value.nameEn
            : nameEn // ignore: cast_nullable_to_non_nullable
                  as String,
        geographyId: null == geographyId
            ? _value.geographyId
            : geographyId // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$ProvinceImpl implements _Province {
  const _$ProvinceImpl({
    required this.id,
    required this.nameTh,
    required this.nameEn,
    required this.geographyId,
  });

  @override
  final int id;
  @override
  final String nameTh;
  @override
  final String nameEn;
  @override
  final int geographyId;

  @override
  String toString() {
    return 'Province(id: $id, nameTh: $nameTh, nameEn: $nameEn, geographyId: $geographyId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProvinceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nameTh, nameTh) || other.nameTh == nameTh) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.geographyId, geographyId) ||
                other.geographyId == geographyId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, nameTh, nameEn, geographyId);

  /// Create a copy of Province
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProvinceImplCopyWith<_$ProvinceImpl> get copyWith =>
      __$$ProvinceImplCopyWithImpl<_$ProvinceImpl>(this, _$identity);
}

abstract class _Province implements Province {
  const factory _Province({
    required final int id,
    required final String nameTh,
    required final String nameEn,
    required final int geographyId,
  }) = _$ProvinceImpl;

  @override
  int get id;
  @override
  String get nameTh;
  @override
  String get nameEn;
  @override
  int get geographyId;

  /// Create a copy of Province
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProvinceImplCopyWith<_$ProvinceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
