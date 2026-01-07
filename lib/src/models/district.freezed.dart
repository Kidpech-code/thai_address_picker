// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'district.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$District {
  int get id => throw _privateConstructorUsedError;
  String get nameTh => throw _privateConstructorUsedError;
  String get nameEn => throw _privateConstructorUsedError;
  int get provinceId => throw _privateConstructorUsedError;

  /// Create a copy of District
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DistrictCopyWith<District> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DistrictCopyWith<$Res> {
  factory $DistrictCopyWith(District value, $Res Function(District) then) =
      _$DistrictCopyWithImpl<$Res, District>;
  @useResult
  $Res call({int id, String nameTh, String nameEn, int provinceId});
}

/// @nodoc
class _$DistrictCopyWithImpl<$Res, $Val extends District>
    implements $DistrictCopyWith<$Res> {
  _$DistrictCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of District
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameTh = null,
    Object? nameEn = null,
    Object? provinceId = null,
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
            provinceId: null == provinceId
                ? _value.provinceId
                : provinceId // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DistrictImplCopyWith<$Res>
    implements $DistrictCopyWith<$Res> {
  factory _$$DistrictImplCopyWith(
    _$DistrictImpl value,
    $Res Function(_$DistrictImpl) then,
  ) = __$$DistrictImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String nameTh, String nameEn, int provinceId});
}

/// @nodoc
class __$$DistrictImplCopyWithImpl<$Res>
    extends _$DistrictCopyWithImpl<$Res, _$DistrictImpl>
    implements _$$DistrictImplCopyWith<$Res> {
  __$$DistrictImplCopyWithImpl(
    _$DistrictImpl _value,
    $Res Function(_$DistrictImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of District
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameTh = null,
    Object? nameEn = null,
    Object? provinceId = null,
  }) {
    return _then(
      _$DistrictImpl(
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
        provinceId: null == provinceId
            ? _value.provinceId
            : provinceId // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$DistrictImpl implements _District {
  const _$DistrictImpl({
    required this.id,
    required this.nameTh,
    required this.nameEn,
    required this.provinceId,
  });

  @override
  final int id;
  @override
  final String nameTh;
  @override
  final String nameEn;
  @override
  final int provinceId;

  @override
  String toString() {
    return 'District(id: $id, nameTh: $nameTh, nameEn: $nameEn, provinceId: $provinceId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DistrictImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nameTh, nameTh) || other.nameTh == nameTh) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.provinceId, provinceId) ||
                other.provinceId == provinceId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, nameTh, nameEn, provinceId);

  /// Create a copy of District
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DistrictImplCopyWith<_$DistrictImpl> get copyWith =>
      __$$DistrictImplCopyWithImpl<_$DistrictImpl>(this, _$identity);
}

abstract class _District implements District {
  const factory _District({
    required final int id,
    required final String nameTh,
    required final String nameEn,
    required final int provinceId,
  }) = _$DistrictImpl;

  @override
  int get id;
  @override
  String get nameTh;
  @override
  String get nameEn;
  @override
  int get provinceId;

  /// Create a copy of District
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DistrictImplCopyWith<_$DistrictImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
