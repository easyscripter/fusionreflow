// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'import_update.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ImportUpdate {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportUpdate);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ImportUpdate()';
}


}

/// @nodoc
class $ImportUpdateCopyWith<$Res>  {
$ImportUpdateCopyWith(ImportUpdate _, $Res Function(ImportUpdate) __);
}


/// Adds pattern-matching-related methods to [ImportUpdate].
extension ImportUpdatePatterns on ImportUpdate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ImportProgress value)?  progress,TResult Function( ImportConverted value)?  converted,TResult Function( ImportFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ImportProgress() when progress != null:
return progress(_that);case ImportConverted() when converted != null:
return converted(_that);case ImportFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ImportProgress value)  progress,required TResult Function( ImportConverted value)  converted,required TResult Function( ImportFailed value)  failed,}){
final _that = this;
switch (_that) {
case ImportProgress():
return progress(_that);case ImportConverted():
return converted(_that);case ImportFailed():
return failed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ImportProgress value)?  progress,TResult? Function( ImportConverted value)?  converted,TResult? Function( ImportFailed value)?  failed,}){
final _that = this;
switch (_that) {
case ImportProgress() when progress != null:
return progress(_that);case ImportConverted() when converted != null:
return converted(_that);case ImportFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int done,  int total)?  progress,TResult Function( Uint8List bytes)?  converted,TResult Function( ImportFailure failure)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ImportProgress() when progress != null:
return progress(_that.done,_that.total);case ImportConverted() when converted != null:
return converted(_that.bytes);case ImportFailed() when failed != null:
return failed(_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int done,  int total)  progress,required TResult Function( Uint8List bytes)  converted,required TResult Function( ImportFailure failure)  failed,}) {final _that = this;
switch (_that) {
case ImportProgress():
return progress(_that.done,_that.total);case ImportConverted():
return converted(_that.bytes);case ImportFailed():
return failed(_that.failure);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int done,  int total)?  progress,TResult? Function( Uint8List bytes)?  converted,TResult? Function( ImportFailure failure)?  failed,}) {final _that = this;
switch (_that) {
case ImportProgress() when progress != null:
return progress(_that.done,_that.total);case ImportConverted() when converted != null:
return converted(_that.bytes);case ImportFailed() when failed != null:
return failed(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class ImportProgress implements ImportUpdate {
  const ImportProgress({required this.done, required this.total});
  

 final  int done;
 final  int total;

/// Create a copy of ImportUpdate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportProgressCopyWith<ImportProgress> get copyWith => _$ImportProgressCopyWithImpl<ImportProgress>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportProgress&&(identical(other.done, done) || other.done == done)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode {
    return Object.hash(runtimeType,done,total);
}

@override
String toString() {
    return 'ImportUpdate.progress(done: $done, total: $total)';
}


}

/// @nodoc
abstract mixin class $ImportProgressCopyWith<$Res> implements $ImportUpdateCopyWith<$Res> {
  factory $ImportProgressCopyWith(ImportProgress value, $Res Function(ImportProgress) _then) = _$ImportProgressCopyWithImpl;
@useResult
$Res call({
 int done, int total
});




}
/// @nodoc
class _$ImportProgressCopyWithImpl<$Res>
    implements $ImportProgressCopyWith<$Res> {
  _$ImportProgressCopyWithImpl(this._self, this._then);

  final ImportProgress _self;
  final $Res Function(ImportProgress) _then;

/// Create a copy of ImportUpdate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? done = null,Object? total = null,}) {
  return _then(ImportProgress(
done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class ImportConverted implements ImportUpdate {
  const ImportConverted(this.bytes);
  

 final  Uint8List bytes;

/// Create a copy of ImportUpdate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportConvertedCopyWith<ImportConverted> get copyWith => _$ImportConvertedCopyWithImpl<ImportConverted>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportConverted&&const DeepCollectionEquality().equals(other.bytes, bytes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(bytes));
}

@override
String toString() {
    return 'ImportUpdate.converted(bytes: $bytes)';
}


}

/// @nodoc
abstract mixin class $ImportConvertedCopyWith<$Res> implements $ImportUpdateCopyWith<$Res> {
  factory $ImportConvertedCopyWith(ImportConverted value, $Res Function(ImportConverted) _then) = _$ImportConvertedCopyWithImpl;
@useResult
$Res call({
 Uint8List bytes
});




}
/// @nodoc
class _$ImportConvertedCopyWithImpl<$Res>
    implements $ImportConvertedCopyWith<$Res> {
  _$ImportConvertedCopyWithImpl(this._self, this._then);

  final ImportConverted _self;
  final $Res Function(ImportConverted) _then;

/// Create a copy of ImportUpdate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? bytes = null,}) {
  return _then(ImportConverted(
null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as Uint8List,
  ));
}


}

/// @nodoc


class ImportFailed implements ImportUpdate {
  const ImportFailed(this.failure);
  

 final  ImportFailure failure;

/// Create a copy of ImportUpdate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportFailedCopyWith<ImportFailed> get copyWith => _$ImportFailedCopyWithImpl<ImportFailed>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportFailed&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,failure);
}

@override
String toString() {
    return 'ImportUpdate.failed(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $ImportFailedCopyWith<$Res> implements $ImportUpdateCopyWith<$Res> {
  factory $ImportFailedCopyWith(ImportFailed value, $Res Function(ImportFailed) _then) = _$ImportFailedCopyWithImpl;
@useResult
$Res call({
 ImportFailure failure
});




}
/// @nodoc
class _$ImportFailedCopyWithImpl<$Res>
    implements $ImportFailedCopyWith<$Res> {
  _$ImportFailedCopyWithImpl(this._self, this._then);

  final ImportFailed _self;
  final $Res Function(ImportFailed) _then;

/// Create a copy of ImportUpdate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(ImportFailed(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as ImportFailure,
  ));
}


}

// dart format on
