// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'import_source.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ImportSource {

/// content:// от системного выбора.
 String get uri;/// Имя файла для показа.
 String get name;/// По расширению; null — формат не поддерживается.
 BookFormat? get format; int? get sizeBytes;
/// Create a copy of ImportSource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportSourceCopyWith<ImportSource> get copyWith => _$ImportSourceCopyWithImpl<ImportSource>(this as ImportSource, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ImportSource;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportSource&&(identical(other.uri, _this.uri) || other.uri == _this.uri)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.format, _this.format) || other.format == _this.format)&&(identical(other.sizeBytes, _this.sizeBytes) || other.sizeBytes == _this.sizeBytes));
}


@override
int get hashCode {
  final _this = this as ImportSource;
  return Object.hash(runtimeType,_this.uri,_this.name,_this.format,_this.sizeBytes);
}

@override
String toString() {
  final _this = this as ImportSource;
  return 'ImportSource(uri: ${_this.uri}, name: ${_this.name}, format: ${_this.format}, sizeBytes: ${_this.sizeBytes})';
}


}

/// @nodoc
abstract mixin class $ImportSourceCopyWith<$Res>  {
  factory $ImportSourceCopyWith(ImportSource value, $Res Function(ImportSource) _then) = _$ImportSourceCopyWithImpl;
@useResult
$Res call({
 String uri, String name, BookFormat? format, int? sizeBytes
});




}
/// @nodoc
class _$ImportSourceCopyWithImpl<$Res>
    implements $ImportSourceCopyWith<$Res> {
  _$ImportSourceCopyWithImpl(this._self, this._then);

  final ImportSource _self;
  final $Res Function(ImportSource) _then;

/// Create a copy of ImportSource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uri = null,Object? name = null,Object? format = freezed,Object? sizeBytes = freezed,}) {
  return _then(ImportSource(
uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,format: freezed == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as BookFormat?,sizeBytes: freezed == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ImportSource].
extension ImportSourcePatterns on ImportSource {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImportSource value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImportSource() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImportSource value)  $default,){
final _that = this;
switch (_that) {
case _ImportSource():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImportSource value)?  $default,){
final _that = this;
switch (_that) {
case _ImportSource() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uri,  String name,  BookFormat? format,  int? sizeBytes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImportSource() when $default != null:
return $default(_that.uri,_that.name,_that.format,_that.sizeBytes);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uri,  String name,  BookFormat? format,  int? sizeBytes)  $default,) {final _that = this;
switch (_that) {
case _ImportSource():
return $default(_that.uri,_that.name,_that.format,_that.sizeBytes);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uri,  String name,  BookFormat? format,  int? sizeBytes)?  $default,) {final _that = this;
switch (_that) {
case _ImportSource() when $default != null:
return $default(_that.uri,_that.name,_that.format,_that.sizeBytes);case _:
  return null;

}
}

}

/// @nodoc


class _ImportSource implements ImportSource {
  const _ImportSource({required this.uri, required this.name, this.format, this.sizeBytes});
  

/// content:// от системного выбора.
@override final  String uri;
/// Имя файла для показа.
@override final  String name;
/// По расширению; null — формат не поддерживается.
@override final  BookFormat? format;
@override final  int? sizeBytes;

/// Create a copy of ImportSource
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImportSourceCopyWith<_ImportSource> get copyWith => __$ImportSourceCopyWithImpl<_ImportSource>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImportSource&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.name, name) || other.name == name)&&(identical(other.format, format) || other.format == format)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,uri,name,format,sizeBytes);
}

@override
String toString() {
    return 'ImportSource(uri: $uri, name: $name, format: $format, sizeBytes: $sizeBytes)';
}


}

/// @nodoc
abstract mixin class _$ImportSourceCopyWith<$Res> implements $ImportSourceCopyWith<$Res> {
  factory _$ImportSourceCopyWith(_ImportSource value, $Res Function(_ImportSource) _then) = __$ImportSourceCopyWithImpl;
@override @useResult
$Res call({
 String uri, String name, BookFormat? format, int? sizeBytes
});




}
/// @nodoc
class __$ImportSourceCopyWithImpl<$Res>
    implements _$ImportSourceCopyWith<$Res> {
  __$ImportSourceCopyWithImpl(this._self, this._then);

  final _ImportSource _self;
  final $Res Function(_ImportSource) _then;

/// Create a copy of ImportSource
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uri = null,Object? name = null,Object? format = freezed,Object? sizeBytes = freezed,}) {
  return _then(_ImportSource(
uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,format: freezed == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as BookFormat?,sizeBytes: freezed == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
