// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reader_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReaderState {

 FlowBook get book;/// Chapter and the offset of the first character of the current page.
 ReadingPosition get position;/// Length of every chapter (sum of its blocks), for the progress.
 List<int> get chapterLengths;/// Laid out chapters (current ± 1) by chapter index.
 Map<int, List<FlowPage>> get pages;/// Current page in the current chapter.
 int get pageIndex;/// Size the pages were laid out for; null until the screen reports it.
 Size? get viewport; FlowStyle? get style;/// How many times saving the position failed (the screen shows a message
/// when it grows).
 int get saveFailures;
/// Create a copy of ReaderState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReaderStateCopyWith<ReaderState> get copyWith => _$ReaderStateCopyWithImpl<ReaderState>(this as ReaderState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ReaderState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReaderState&&(identical(other.book, _this.book) || other.book == _this.book)&&(identical(other.position, _this.position) || other.position == _this.position)&&const DeepCollectionEquality().equals(other.chapterLengths, _this.chapterLengths)&&const DeepCollectionEquality().equals(other.pages, _this.pages)&&(identical(other.pageIndex, _this.pageIndex) || other.pageIndex == _this.pageIndex)&&(identical(other.viewport, _this.viewport) || other.viewport == _this.viewport)&&(identical(other.style, _this.style) || other.style == _this.style)&&(identical(other.saveFailures, _this.saveFailures) || other.saveFailures == _this.saveFailures));
}


@override
int get hashCode {
  final _this = this as ReaderState;
  return Object.hash(runtimeType,_this.book,_this.position,const DeepCollectionEquality().hash(_this.chapterLengths),const DeepCollectionEquality().hash(_this.pages),_this.pageIndex,_this.viewport,_this.style,_this.saveFailures);
}

@override
String toString() {
  final _this = this as ReaderState;
  return 'ReaderState(book: ${_this.book}, position: ${_this.position}, chapterLengths: ${_this.chapterLengths}, pages: ${_this.pages}, pageIndex: ${_this.pageIndex}, viewport: ${_this.viewport}, style: ${_this.style}, saveFailures: ${_this.saveFailures})';
}


}

/// @nodoc
abstract mixin class $ReaderStateCopyWith<$Res>  {
  factory $ReaderStateCopyWith(ReaderState value, $Res Function(ReaderState) _then) = _$ReaderStateCopyWithImpl;
@useResult
$Res call({
 FlowBook book, ReadingPosition position, List<int> chapterLengths, Map<int, List<FlowPage>> pages, int pageIndex, Size? viewport, FlowStyle? style, int saveFailures
});


$ReadingPositionCopyWith<$Res> get position;

}
/// @nodoc
class _$ReaderStateCopyWithImpl<$Res>
    implements $ReaderStateCopyWith<$Res> {
  _$ReaderStateCopyWithImpl(this._self, this._then);

  final ReaderState _self;
  final $Res Function(ReaderState) _then;

/// Create a copy of ReaderState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? book = null,Object? position = null,Object? chapterLengths = null,Object? pages = null,Object? pageIndex = null,Object? viewport = freezed,Object? style = freezed,Object? saveFailures = null,}) {
  return _then(ReaderState(
book: null == book ? _self.book : book // ignore: cast_nullable_to_non_nullable
as FlowBook,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as ReadingPosition,chapterLengths: null == chapterLengths ? _self.chapterLengths : chapterLengths // ignore: cast_nullable_to_non_nullable
as List<int>,pages: null == pages ? _self.pages : pages // ignore: cast_nullable_to_non_nullable
as Map<int, List<FlowPage>>,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,viewport: freezed == viewport ? _self.viewport : viewport // ignore: cast_nullable_to_non_nullable
as Size?,style: freezed == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as FlowStyle?,saveFailures: null == saveFailures ? _self.saveFailures : saveFailures // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of ReaderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReadingPositionCopyWith<$Res> get position {
  
  return $ReadingPositionCopyWith<$Res>(_self.position, (value) {
    return _then(_self.copyWith(position: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReaderState].
extension ReaderStatePatterns on ReaderState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReaderState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReaderState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReaderState value)  $default,){
final _that = this;
switch (_that) {
case _ReaderState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReaderState value)?  $default,){
final _that = this;
switch (_that) {
case _ReaderState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FlowBook book,  ReadingPosition position,  List<int> chapterLengths,  Map<int, List<FlowPage>> pages,  int pageIndex,  Size? viewport,  FlowStyle? style,  int saveFailures)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReaderState() when $default != null:
return $default(_that.book,_that.position,_that.chapterLengths,_that.pages,_that.pageIndex,_that.viewport,_that.style,_that.saveFailures);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FlowBook book,  ReadingPosition position,  List<int> chapterLengths,  Map<int, List<FlowPage>> pages,  int pageIndex,  Size? viewport,  FlowStyle? style,  int saveFailures)  $default,) {final _that = this;
switch (_that) {
case _ReaderState():
return $default(_that.book,_that.position,_that.chapterLengths,_that.pages,_that.pageIndex,_that.viewport,_that.style,_that.saveFailures);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FlowBook book,  ReadingPosition position,  List<int> chapterLengths,  Map<int, List<FlowPage>> pages,  int pageIndex,  Size? viewport,  FlowStyle? style,  int saveFailures)?  $default,) {final _that = this;
switch (_that) {
case _ReaderState() when $default != null:
return $default(_that.book,_that.position,_that.chapterLengths,_that.pages,_that.pageIndex,_that.viewport,_that.style,_that.saveFailures);case _:
  return null;

}
}

}

/// @nodoc


class _ReaderState implements ReaderState {
  const _ReaderState({required this.book, required this.position, required  List<int> chapterLengths,  Map<int, List<FlowPage>> pages = const {}, this.pageIndex = 0, this.viewport, this.style, this.saveFailures = 0}): _chapterLengths = chapterLengths,_pages = pages;
  

@override final  FlowBook book;
/// Chapter and the offset of the first character of the current page.
@override final  ReadingPosition position;
/// Length of every chapter (sum of its blocks), for the progress.
 final  List<int> _chapterLengths;
/// Length of every chapter (sum of its blocks), for the progress.
@override List<int> get chapterLengths {
  if (_chapterLengths is EqualUnmodifiableListView) return _chapterLengths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chapterLengths);
}

/// Laid out chapters (current ± 1) by chapter index.
 final  Map<int, List<FlowPage>> _pages;
/// Laid out chapters (current ± 1) by chapter index.
@override@JsonKey() Map<int, List<FlowPage>> get pages {
  if (_pages is EqualUnmodifiableMapView) return _pages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_pages);
}

/// Current page in the current chapter.
@override@JsonKey() final  int pageIndex;
/// Size the pages were laid out for; null until the screen reports it.
@override final  Size? viewport;
@override final  FlowStyle? style;
/// How many times saving the position failed (the screen shows a message
/// when it grows).
@override@JsonKey() final  int saveFailures;

/// Create a copy of ReaderState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReaderStateCopyWith<_ReaderState> get copyWith => __$ReaderStateCopyWithImpl<_ReaderState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReaderState&&(identical(other.book, book) || other.book == book)&&(identical(other.position, position) || other.position == position)&&const DeepCollectionEquality().equals(other.chapterLengths, _chapterLengths)&&const DeepCollectionEquality().equals(other.pages, _pages)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex)&&(identical(other.viewport, viewport) || other.viewport == viewport)&&(identical(other.style, style) || other.style == style)&&(identical(other.saveFailures, saveFailures) || other.saveFailures == saveFailures));
}


@override
int get hashCode {
    return Object.hash(runtimeType,book,position,const DeepCollectionEquality().hash(_chapterLengths),const DeepCollectionEquality().hash(_pages),pageIndex,viewport,style,saveFailures);
}

@override
String toString() {
    return 'ReaderState(book: $book, position: $position, chapterLengths: $chapterLengths, pages: $pages, pageIndex: $pageIndex, viewport: $viewport, style: $style, saveFailures: $saveFailures)';
}


}

/// @nodoc
abstract mixin class _$ReaderStateCopyWith<$Res> implements $ReaderStateCopyWith<$Res> {
  factory _$ReaderStateCopyWith(_ReaderState value, $Res Function(_ReaderState) _then) = __$ReaderStateCopyWithImpl;
@override @useResult
$Res call({
 FlowBook book, ReadingPosition position, List<int> chapterLengths, Map<int, List<FlowPage>> pages, int pageIndex, Size? viewport, FlowStyle? style, int saveFailures
});


@override $ReadingPositionCopyWith<$Res> get position;

}
/// @nodoc
class __$ReaderStateCopyWithImpl<$Res>
    implements _$ReaderStateCopyWith<$Res> {
  __$ReaderStateCopyWithImpl(this._self, this._then);

  final _ReaderState _self;
  final $Res Function(_ReaderState) _then;

/// Create a copy of ReaderState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? book = null,Object? position = null,Object? chapterLengths = null,Object? pages = null,Object? pageIndex = null,Object? viewport = freezed,Object? style = freezed,Object? saveFailures = null,}) {
  return _then(_ReaderState(
book: null == book ? _self.book : book // ignore: cast_nullable_to_non_nullable
as FlowBook,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as ReadingPosition,chapterLengths: null == chapterLengths ? _self._chapterLengths : chapterLengths // ignore: cast_nullable_to_non_nullable
as List<int>,pages: null == pages ? _self._pages : pages // ignore: cast_nullable_to_non_nullable
as Map<int, List<FlowPage>>,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,viewport: freezed == viewport ? _self.viewport : viewport // ignore: cast_nullable_to_non_nullable
as Size?,style: freezed == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as FlowStyle?,saveFailures: null == saveFailures ? _self.saveFailures : saveFailures // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of ReaderState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReadingPositionCopyWith<$Res> get position {
  
  return $ReadingPositionCopyWith<$Res>(_self.position, (value) {
    return _then(_self.copyWith(position: value));
  });
}
}

// dart format on
