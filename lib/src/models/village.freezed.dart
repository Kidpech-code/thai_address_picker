// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'village.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Village {
  int get id => throw _privateConstructorUsedError;
  String get nameTh => throw _privateConstructorUsedError;
  int get mooNo => throw _privateConstructorUsedError;
  int get subDistrictId => throw _privateConstructorUsedError;
  double? get lat => throw _privateConstructorUsedError;
  double? get long => throw _privateConstructorUsedError;

  /// Create a copy of Village
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VillageCopyWith<Village> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VillageCopyWith<$Res> {
  factory $VillageCopyWith(Village value, $Res Function(Village) then) =
      _$VillageCopyWithImpl<$Res, Village>;
  @useResult
  $Res call({
    int id,
    String nameTh,
    int mooNo,
    int subDistrictId,
    double? lat,
    double? long,
  });
}

/// @nodoc
class _$VillageCopyWithImpl<$Res, $Val extends Village>
    implements $VillageCopyWith<$Res> {
  _$VillageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Village
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameTh = null,
    Object? mooNo = null,
    Object? subDistrictId = null,
    Object? lat = freezed,
    Object? long = freezed,
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
            mooNo: null == mooNo
                ? _value.mooNo
                : mooNo // ignore: cast_nullable_to_non_nullable
                      as int,
            subDistrictId: null == subDistrictId
                ? _value.subDistrictId
                : subDistrictId // ignore: cast_nullable_to_non_nullable
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
abstract class _$$VillageImplCopyWith<$Res> implements $VillageCopyWith<$Res> {
  factory _$$VillageImplCopyWith(
    _$VillageImpl value,
    $Res Function(_$VillageImpl) then,
  ) = __$$VillageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String nameTh,
    int mooNo,
    int subDistrictId,
    double? lat,
    double? long,
  });
}

/// @nodoc
class __$$VillageImplCopyWithImpl<$Res>
    extends _$VillageCopyWithImpl<$Res, _$VillageImpl>
    implements _$$VillageImplCopyWith<$Res> {
  __$$VillageImplCopyWithImpl(
    _$VillageImpl _value,
    $Res Function(_$VillageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Village
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameTh = null,
    Object? mooNo = null,
    Object? subDistrictId = null,
    Object? lat = freezed,
    Object? long = freezed,
  }) {
    return _then(
      _$VillageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        nameTh: null == nameTh
            ? _value.nameTh
            : nameTh // ignore: cast_nullable_to_non_nullable
                  as String,
        mooNo: null == mooNo
            ? _value.mooNo
            : mooNo // ignore: cast_nullable_to_non_nullable
                  as int,
        subDistrictId: null == subDistrictId
            ? _value.subDistrictId
            : subDistrictId // ignore: cast_nullable_to_non_nullable
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

class _$VillageImpl implements _Village {
  const _$VillageImpl({
    required this.id,
    required this.nameTh,
    required this.mooNo,
    required this.subDistrictId,
    required this.lat,
    required this.long,
  });

  @override
  final int id;
  @override
  final String nameTh;
  @override
  final int mooNo;
  @override
  final int subDistrictId;
  @override
  final double? lat;
  @override
  final double? long;

  @override
  String toString() {
    return 'Village(id: $id, nameTh: $nameTh, mooNo: $mooNo, subDistrictId: $subDistrictId, lat: $lat, long: $long)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VillageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nameTh, nameTh) || other.nameTh == nameTh) &&
            (identical(other.mooNo, mooNo) || other.mooNo == mooNo) &&
            (identical(other.subDistrictId, subDistrictId) ||
                other.subDistrictId == subDistrictId) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.long, long) || other.long == long));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, nameTh, mooNo, subDistrictId, lat, long);

  /// Create a copy of Village
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VillageImplCopyWith<_$VillageImpl> get copyWith =>
      __$$VillageImplCopyWithImpl<_$VillageImpl>(this, _$identity);
}

abstract class _Village implements Village {
  const factory _Village({
    required final int id,
    required final String nameTh,
    required final int mooNo,
    required final int subDistrictId,
    required final double? lat,
    required final double? long,
  }) = _$VillageImpl;

  @override
  int get id;
  @override
  String get nameTh;
  @override
  int get mooNo;
  @override
  int get subDistrictId;
  @override
  double? get lat;
  @override
  double? get long;

  /// Create a copy of Village
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VillageImplCopyWith<_$VillageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
