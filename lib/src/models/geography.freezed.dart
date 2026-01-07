// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'geography.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Geography _$GeographyFromJson(Map<String, dynamic> json) {
  return _Geography.fromJson(json);
}

/// @nodoc
mixin _$Geography {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// Serializes this Geography to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Geography
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GeographyCopyWith<Geography> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GeographyCopyWith<$Res> {
  factory $GeographyCopyWith(Geography value, $Res Function(Geography) then) =
      _$GeographyCopyWithImpl<$Res, Geography>;
  @useResult
  $Res call({int id, String name});
}

/// @nodoc
class _$GeographyCopyWithImpl<$Res, $Val extends Geography>
    implements $GeographyCopyWith<$Res> {
  _$GeographyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Geography
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null}) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GeographyImplCopyWith<$Res>
    implements $GeographyCopyWith<$Res> {
  factory _$$GeographyImplCopyWith(
    _$GeographyImpl value,
    $Res Function(_$GeographyImpl) then,
  ) = __$$GeographyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String name});
}

/// @nodoc
class __$$GeographyImplCopyWithImpl<$Res>
    extends _$GeographyCopyWithImpl<$Res, _$GeographyImpl>
    implements _$$GeographyImplCopyWith<$Res> {
  __$$GeographyImplCopyWithImpl(
    _$GeographyImpl _value,
    $Res Function(_$GeographyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Geography
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null}) {
    return _then(
      _$GeographyImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GeographyImpl implements _Geography {
  const _$GeographyImpl({required this.id, required this.name});

  factory _$GeographyImpl.fromJson(Map<String, dynamic> json) =>
      _$$GeographyImplFromJson(json);

  @override
  final int id;
  @override
  final String name;

  @override
  String toString() {
    return 'Geography(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GeographyImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  /// Create a copy of Geography
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GeographyImplCopyWith<_$GeographyImpl> get copyWith =>
      __$$GeographyImplCopyWithImpl<_$GeographyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GeographyImplToJson(this);
  }
}

abstract class _Geography implements Geography {
  const factory _Geography({
    required final int id,
    required final String name,
  }) = _$GeographyImpl;

  factory _Geography.fromJson(Map<String, dynamic> json) =
      _$GeographyImpl.fromJson;

  @override
  int get id;
  @override
  String get name;

  /// Create a copy of Geography
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GeographyImplCopyWith<_$GeographyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
