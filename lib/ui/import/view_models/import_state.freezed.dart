// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'import_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ImportState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ImportState()';
}


}

/// @nodoc
class $ImportStateCopyWith<$Res>  {
$ImportStateCopyWith(ImportState _, $Res Function(ImportState) __);
}


/// Adds pattern-matching-related methods to [ImportState].
extension ImportStatePatterns on ImportState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ImportIdle value)?  idle,TResult Function( ImportRunning value)?  running,TResult Function( ImportFailedState value)?  failed,TResult Function( ImportAdded value)?  added,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ImportIdle() when idle != null:
return idle(_that);case ImportRunning() when running != null:
return running(_that);case ImportFailedState() when failed != null:
return failed(_that);case ImportAdded() when added != null:
return added(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ImportIdle value)  idle,required TResult Function( ImportRunning value)  running,required TResult Function( ImportFailedState value)  failed,required TResult Function( ImportAdded value)  added,}){
final _that = this;
switch (_that) {
case ImportIdle():
return idle(_that);case ImportRunning():
return running(_that);case ImportFailedState():
return failed(_that);case ImportAdded():
return added(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ImportIdle value)?  idle,TResult? Function( ImportRunning value)?  running,TResult? Function( ImportFailedState value)?  failed,TResult? Function( ImportAdded value)?  added,}){
final _that = this;
switch (_that) {
case ImportIdle() when idle != null:
return idle(_that);case ImportRunning() when running != null:
return running(_that);case ImportFailedState() when failed != null:
return failed(_that);case ImportAdded() when added != null:
return added(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function( ImportSource source,  int? done,  int? total)?  running,TResult Function( ImportSource source,  ImportFailure failure)?  failed,TResult Function( String bookId)?  added,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ImportIdle() when idle != null:
return idle();case ImportRunning() when running != null:
return running(_that.source,_that.done,_that.total);case ImportFailedState() when failed != null:
return failed(_that.source,_that.failure);case ImportAdded() when added != null:
return added(_that.bookId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function( ImportSource source,  int? done,  int? total)  running,required TResult Function( ImportSource source,  ImportFailure failure)  failed,required TResult Function( String bookId)  added,}) {final _that = this;
switch (_that) {
case ImportIdle():
return idle();case ImportRunning():
return running(_that.source,_that.done,_that.total);case ImportFailedState():
return failed(_that.source,_that.failure);case ImportAdded():
return added(_that.bookId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function( ImportSource source,  int? done,  int? total)?  running,TResult? Function( ImportSource source,  ImportFailure failure)?  failed,TResult? Function( String bookId)?  added,}) {final _that = this;
switch (_that) {
case ImportIdle() when idle != null:
return idle();case ImportRunning() when running != null:
return running(_that.source,_that.done,_that.total);case ImportFailedState() when failed != null:
return failed(_that.source,_that.failure);case ImportAdded() when added != null:
return added(_that.bookId);case _:
  return null;

}
}

}

/// @nodoc


class ImportIdle implements ImportState {
  const ImportIdle();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ImportState.idle()';
}


}




/// @nodoc


class ImportRunning implements ImportState {
  const ImportRunning({required this.source, this.done, this.total});
  

 final  ImportSource source;
 final  int? done;
 final  int? total;

/// Create a copy of ImportState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportRunningCopyWith<ImportRunning> get copyWith => _$ImportRunningCopyWithImpl<ImportRunning>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportRunning&&(identical(other.source, source) || other.source == source)&&(identical(other.done, done) || other.done == done)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode {
    return Object.hash(runtimeType,source,done,total);
}

@override
String toString() {
    return 'ImportState.running(source: $source, done: $done, total: $total)';
}


}

/// @nodoc
abstract mixin class $ImportRunningCopyWith<$Res> implements $ImportStateCopyWith<$Res> {
  factory $ImportRunningCopyWith(ImportRunning value, $Res Function(ImportRunning) _then) = _$ImportRunningCopyWithImpl;
@useResult
$Res call({
 ImportSource source, int? done, int? total
});


$ImportSourceCopyWith<$Res> get source;

}
/// @nodoc
class _$ImportRunningCopyWithImpl<$Res>
    implements $ImportRunningCopyWith<$Res> {
  _$ImportRunningCopyWithImpl(this._self, this._then);

  final ImportRunning _self;
  final $Res Function(ImportRunning) _then;

/// Create a copy of ImportState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? source = null,Object? done = freezed,Object? total = freezed,}) {
  return _then(ImportRunning(
source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as ImportSource,done: freezed == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as int?,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of ImportState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImportSourceCopyWith<$Res> get source {
  
  return $ImportSourceCopyWith<$Res>(_self.source, (value) {
    return _then(_self.copyWith(source: value));
  });
}
}

/// @nodoc


class ImportFailedState implements ImportState {
  const ImportFailedState({required this.source, required this.failure});
  

 final  ImportSource source;
 final  ImportFailure failure;

/// Create a copy of ImportState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportFailedStateCopyWith<ImportFailedState> get copyWith => _$ImportFailedStateCopyWithImpl<ImportFailedState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportFailedState&&(identical(other.source, source) || other.source == source)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,source,failure);
}

@override
String toString() {
    return 'ImportState.failed(source: $source, failure: $failure)';
}


}

/// @nodoc
abstract mixin class $ImportFailedStateCopyWith<$Res> implements $ImportStateCopyWith<$Res> {
  factory $ImportFailedStateCopyWith(ImportFailedState value, $Res Function(ImportFailedState) _then) = _$ImportFailedStateCopyWithImpl;
@useResult
$Res call({
 ImportSource source, ImportFailure failure
});


$ImportSourceCopyWith<$Res> get source;

}
/// @nodoc
class _$ImportFailedStateCopyWithImpl<$Res>
    implements $ImportFailedStateCopyWith<$Res> {
  _$ImportFailedStateCopyWithImpl(this._self, this._then);

  final ImportFailedState _self;
  final $Res Function(ImportFailedState) _then;

/// Create a copy of ImportState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? source = null,Object? failure = null,}) {
  return _then(ImportFailedState(
source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as ImportSource,failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as ImportFailure,
  ));
}

/// Create a copy of ImportState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImportSourceCopyWith<$Res> get source {
  
  return $ImportSourceCopyWith<$Res>(_self.source, (value) {
    return _then(_self.copyWith(source: value));
  });
}
}

/// @nodoc


class ImportAdded implements ImportState {
  const ImportAdded({required this.bookId});
  

 final  String bookId;

/// Create a copy of ImportState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportAddedCopyWith<ImportAdded> get copyWith => _$ImportAddedCopyWithImpl<ImportAdded>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportAdded&&(identical(other.bookId, bookId) || other.bookId == bookId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,bookId);
}

@override
String toString() {
    return 'ImportState.added(bookId: $bookId)';
}


}

/// @nodoc
abstract mixin class $ImportAddedCopyWith<$Res> implements $ImportStateCopyWith<$Res> {
  factory $ImportAddedCopyWith(ImportAdded value, $Res Function(ImportAdded) _then) = _$ImportAddedCopyWithImpl;
@useResult
$Res call({
 String bookId
});




}
/// @nodoc
class _$ImportAddedCopyWithImpl<$Res>
    implements $ImportAddedCopyWith<$Res> {
  _$ImportAddedCopyWithImpl(this._self, this._then);

  final ImportAdded _self;
  final $Res Function(ImportAdded) _then;

/// Create a copy of ImportState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? bookId = null,}) {
  return _then(ImportAdded(
bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
