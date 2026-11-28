// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'library_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LibraryState {

/// Сетка: все книги (и [continueReading] тоже) в порядке [sort].
 List<BookEntry> get books;/// Все живые книги (счётчик «8 книг»).
 int get totalCount; LibrarySort get sort;/// Книга с наибольшим lastReadAt, кроме прочитанных.
 BookEntry? get continueReading;
/// Create a copy of LibraryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LibraryStateCopyWith<LibraryState> get copyWith => _$LibraryStateCopyWithImpl<LibraryState>(this as LibraryState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LibraryState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LibraryState&&const DeepCollectionEquality().equals(other.books, _this.books)&&(identical(other.totalCount, _this.totalCount) || other.totalCount == _this.totalCount)&&(identical(other.sort, _this.sort) || other.sort == _this.sort)&&(identical(other.continueReading, _this.continueReading) || other.continueReading == _this.continueReading));
}


@override
int get hashCode {
  final _this = this as LibraryState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.books),_this.totalCount,_this.sort,_this.continueReading);
}

@override
String toString() {
  final _this = this as LibraryState;
  return 'LibraryState(books: ${_this.books}, totalCount: ${_this.totalCount}, sort: ${_this.sort}, continueReading: ${_this.continueReading})';
}


}

/// @nodoc
abstract mixin class $LibraryStateCopyWith<$Res>  {
  factory $LibraryStateCopyWith(LibraryState value, $Res Function(LibraryState) _then) = _$LibraryStateCopyWithImpl;
@useResult
$Res call({
 List<BookEntry> books, int totalCount, LibrarySort sort, BookEntry? continueReading
});


$BookEntryCopyWith<$Res>? get continueReading;

}
/// @nodoc
class _$LibraryStateCopyWithImpl<$Res>
    implements $LibraryStateCopyWith<$Res> {
  _$LibraryStateCopyWithImpl(this._self, this._then);

  final LibraryState _self;
  final $Res Function(LibraryState) _then;

/// Create a copy of LibraryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? books = null,Object? totalCount = null,Object? sort = null,Object? continueReading = freezed,}) {
  return _then(LibraryState(
books: null == books ? _self.books : books // ignore: cast_nullable_to_non_nullable
as List<BookEntry>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as LibrarySort,continueReading: freezed == continueReading ? _self.continueReading : continueReading // ignore: cast_nullable_to_non_nullable
as BookEntry?,
  ));
}
/// Create a copy of LibraryState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookEntryCopyWith<$Res>? get continueReading {
    if (_self.continueReading == null) {
    return null;
  }

  return $BookEntryCopyWith<$Res>(_self.continueReading!, (value) {
    return _then(_self.copyWith(continueReading: value));
  });
}
}


/// Adds pattern-matching-related methods to [LibraryState].
extension LibraryStatePatterns on LibraryState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LibraryState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LibraryState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LibraryState value)  $default,){
final _that = this;
switch (_that) {
case _LibraryState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LibraryState value)?  $default,){
final _that = this;
switch (_that) {
case _LibraryState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<BookEntry> books,  int totalCount,  LibrarySort sort,  BookEntry? continueReading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LibraryState() when $default != null:
return $default(_that.books,_that.totalCount,_that.sort,_that.continueReading);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<BookEntry> books,  int totalCount,  LibrarySort sort,  BookEntry? continueReading)  $default,) {final _that = this;
switch (_that) {
case _LibraryState():
return $default(_that.books,_that.totalCount,_that.sort,_that.continueReading);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<BookEntry> books,  int totalCount,  LibrarySort sort,  BookEntry? continueReading)?  $default,) {final _that = this;
switch (_that) {
case _LibraryState() when $default != null:
return $default(_that.books,_that.totalCount,_that.sort,_that.continueReading);case _:
  return null;

}
}

}

/// @nodoc


class _LibraryState implements LibraryState {
  const _LibraryState({required  List<BookEntry> books, required this.totalCount, required this.sort, this.continueReading}): _books = books;
  

/// Сетка: все книги (и [continueReading] тоже) в порядке [sort].
 final  List<BookEntry> _books;
/// Сетка: все книги (и [continueReading] тоже) в порядке [sort].
@override List<BookEntry> get books {
  if (_books is EqualUnmodifiableListView) return _books;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_books);
}

/// Все живые книги (счётчик «8 книг»).
@override final  int totalCount;
@override final  LibrarySort sort;
/// Книга с наибольшим lastReadAt, кроме прочитанных.
@override final  BookEntry? continueReading;

/// Create a copy of LibraryState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LibraryStateCopyWith<_LibraryState> get copyWith => __$LibraryStateCopyWithImpl<_LibraryState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LibraryState&&const DeepCollectionEquality().equals(other.books, _books)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.continueReading, continueReading) || other.continueReading == continueReading));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_books),totalCount,sort,continueReading);
}

@override
String toString() {
    return 'LibraryState(books: $books, totalCount: $totalCount, sort: $sort, continueReading: $continueReading)';
}


}

/// @nodoc
abstract mixin class _$LibraryStateCopyWith<$Res> implements $LibraryStateCopyWith<$Res> {
  factory _$LibraryStateCopyWith(_LibraryState value, $Res Function(_LibraryState) _then) = __$LibraryStateCopyWithImpl;
@override @useResult
$Res call({
 List<BookEntry> books, int totalCount, LibrarySort sort, BookEntry? continueReading
});


@override $BookEntryCopyWith<$Res>? get continueReading;

}
/// @nodoc
class __$LibraryStateCopyWithImpl<$Res>
    implements _$LibraryStateCopyWith<$Res> {
  __$LibraryStateCopyWithImpl(this._self, this._then);

  final _LibraryState _self;
  final $Res Function(_LibraryState) _then;

/// Create a copy of LibraryState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? books = null,Object? totalCount = null,Object? sort = null,Object? continueReading = freezed,}) {
  return _then(_LibraryState(
books: null == books ? _self._books : books // ignore: cast_nullable_to_non_nullable
as List<BookEntry>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as LibrarySort,continueReading: freezed == continueReading ? _self.continueReading : continueReading // ignore: cast_nullable_to_non_nullable
as BookEntry?,
  ));
}

/// Create a copy of LibraryState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookEntryCopyWith<$Res>? get continueReading {
    if (_self.continueReading == null) {
    return null;
  }

  return $BookEntryCopyWith<$Res>(_self.continueReading!, (value) {
    return _then(_self.copyWith(continueReading: value));
  });
}
}

// dart format on
