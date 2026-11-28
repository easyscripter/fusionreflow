// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'book.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Block {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Block);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'Block()';
}


}

/// @nodoc
class $BlockCopyWith<$Res>  {
$BlockCopyWith(Block _, $Res Function(Block) __);
}


/// Adds pattern-matching-related methods to [Block].
extension BlockPatterns on Block {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Block_Heading value)?  heading,TResult Function( Block_Paragraph value)?  paragraph,TResult Function( Block_ListItem value)?  listItem,TResult Function( Block_Quote value)?  quote,TResult Function( Block_Code value)?  code,TResult Function( Block_Figure value)?  figure,TResult Function( Block_Formula value)?  formula,TResult Function( Block_Table value)?  table,TResult Function( Block_Footnote value)?  footnote,TResult Function( Block_Separator value)?  separator,TResult Function( Block_FixedPage value)?  fixedPage,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Block_Heading() when heading != null:
return heading(_that);case Block_Paragraph() when paragraph != null:
return paragraph(_that);case Block_ListItem() when listItem != null:
return listItem(_that);case Block_Quote() when quote != null:
return quote(_that);case Block_Code() when code != null:
return code(_that);case Block_Figure() when figure != null:
return figure(_that);case Block_Formula() when formula != null:
return formula(_that);case Block_Table() when table != null:
return table(_that);case Block_Footnote() when footnote != null:
return footnote(_that);case Block_Separator() when separator != null:
return separator(_that);case Block_FixedPage() when fixedPage != null:
return fixedPage(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Block_Heading value)  heading,required TResult Function( Block_Paragraph value)  paragraph,required TResult Function( Block_ListItem value)  listItem,required TResult Function( Block_Quote value)  quote,required TResult Function( Block_Code value)  code,required TResult Function( Block_Figure value)  figure,required TResult Function( Block_Formula value)  formula,required TResult Function( Block_Table value)  table,required TResult Function( Block_Footnote value)  footnote,required TResult Function( Block_Separator value)  separator,required TResult Function( Block_FixedPage value)  fixedPage,}){
final _that = this;
switch (_that) {
case Block_Heading():
return heading(_that);case Block_Paragraph():
return paragraph(_that);case Block_ListItem():
return listItem(_that);case Block_Quote():
return quote(_that);case Block_Code():
return code(_that);case Block_Figure():
return figure(_that);case Block_Formula():
return formula(_that);case Block_Table():
return table(_that);case Block_Footnote():
return footnote(_that);case Block_Separator():
return separator(_that);case Block_FixedPage():
return fixedPage(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Block_Heading value)?  heading,TResult? Function( Block_Paragraph value)?  paragraph,TResult? Function( Block_ListItem value)?  listItem,TResult? Function( Block_Quote value)?  quote,TResult? Function( Block_Code value)?  code,TResult? Function( Block_Figure value)?  figure,TResult? Function( Block_Formula value)?  formula,TResult? Function( Block_Table value)?  table,TResult? Function( Block_Footnote value)?  footnote,TResult? Function( Block_Separator value)?  separator,TResult? Function( Block_FixedPage value)?  fixedPage,}){
final _that = this;
switch (_that) {
case Block_Heading() when heading != null:
return heading(_that);case Block_Paragraph() when paragraph != null:
return paragraph(_that);case Block_ListItem() when listItem != null:
return listItem(_that);case Block_Quote() when quote != null:
return quote(_that);case Block_Code() when code != null:
return code(_that);case Block_Figure() when figure != null:
return figure(_that);case Block_Formula() when formula != null:
return formula(_that);case Block_Table() when table != null:
return table(_that);case Block_Footnote() when footnote != null:
return footnote(_that);case Block_Separator() when separator != null:
return separator(_that);case Block_FixedPage() when fixedPage != null:
return fixedPage(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int level,  List<Inline> inlines)?  heading,TResult Function( List<Inline> inlines)?  paragraph,TResult Function( ListMarker marker,  int depth,  List<Inline> inlines)?  listItem,TResult Function( List<BlockNode> blocks)?  quote,TResult Function( List<String> lines)?  code,TResult Function( ResourceId image,  List<Inline> caption)?  figure,TResult Function( ResourceId image)?  formula,TResult Function( Table field0)?  table,TResult Function( String id,  List<BlockNode> blocks)?  footnote,TResult Function()?  separator,TResult Function( ResourceId image)?  fixedPage,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Block_Heading() when heading != null:
return heading(_that.level,_that.inlines);case Block_Paragraph() when paragraph != null:
return paragraph(_that.inlines);case Block_ListItem() when listItem != null:
return listItem(_that.marker,_that.depth,_that.inlines);case Block_Quote() when quote != null:
return quote(_that.blocks);case Block_Code() when code != null:
return code(_that.lines);case Block_Figure() when figure != null:
return figure(_that.image,_that.caption);case Block_Formula() when formula != null:
return formula(_that.image);case Block_Table() when table != null:
return table(_that.field0);case Block_Footnote() when footnote != null:
return footnote(_that.id,_that.blocks);case Block_Separator() when separator != null:
return separator();case Block_FixedPage() when fixedPage != null:
return fixedPage(_that.image);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int level,  List<Inline> inlines)  heading,required TResult Function( List<Inline> inlines)  paragraph,required TResult Function( ListMarker marker,  int depth,  List<Inline> inlines)  listItem,required TResult Function( List<BlockNode> blocks)  quote,required TResult Function( List<String> lines)  code,required TResult Function( ResourceId image,  List<Inline> caption)  figure,required TResult Function( ResourceId image)  formula,required TResult Function( Table field0)  table,required TResult Function( String id,  List<BlockNode> blocks)  footnote,required TResult Function()  separator,required TResult Function( ResourceId image)  fixedPage,}) {final _that = this;
switch (_that) {
case Block_Heading():
return heading(_that.level,_that.inlines);case Block_Paragraph():
return paragraph(_that.inlines);case Block_ListItem():
return listItem(_that.marker,_that.depth,_that.inlines);case Block_Quote():
return quote(_that.blocks);case Block_Code():
return code(_that.lines);case Block_Figure():
return figure(_that.image,_that.caption);case Block_Formula():
return formula(_that.image);case Block_Table():
return table(_that.field0);case Block_Footnote():
return footnote(_that.id,_that.blocks);case Block_Separator():
return separator();case Block_FixedPage():
return fixedPage(_that.image);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int level,  List<Inline> inlines)?  heading,TResult? Function( List<Inline> inlines)?  paragraph,TResult? Function( ListMarker marker,  int depth,  List<Inline> inlines)?  listItem,TResult? Function( List<BlockNode> blocks)?  quote,TResult? Function( List<String> lines)?  code,TResult? Function( ResourceId image,  List<Inline> caption)?  figure,TResult? Function( ResourceId image)?  formula,TResult? Function( Table field0)?  table,TResult? Function( String id,  List<BlockNode> blocks)?  footnote,TResult? Function()?  separator,TResult? Function( ResourceId image)?  fixedPage,}) {final _that = this;
switch (_that) {
case Block_Heading() when heading != null:
return heading(_that.level,_that.inlines);case Block_Paragraph() when paragraph != null:
return paragraph(_that.inlines);case Block_ListItem() when listItem != null:
return listItem(_that.marker,_that.depth,_that.inlines);case Block_Quote() when quote != null:
return quote(_that.blocks);case Block_Code() when code != null:
return code(_that.lines);case Block_Figure() when figure != null:
return figure(_that.image,_that.caption);case Block_Formula() when formula != null:
return formula(_that.image);case Block_Table() when table != null:
return table(_that.field0);case Block_Footnote() when footnote != null:
return footnote(_that.id,_that.blocks);case Block_Separator() when separator != null:
return separator();case Block_FixedPage() when fixedPage != null:
return fixedPage(_that.image);case _:
  return null;

}
}

}

/// @nodoc


class Block_Heading extends Block {
  const Block_Heading({required this.level, required  List<Inline> inlines}): _inlines = inlines,super._();
  

 final  int level;
 final  List<Inline> _inlines;
 List<Inline> get inlines {
  if (_inlines is EqualUnmodifiableListView) return _inlines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_inlines);
}


/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Block_HeadingCopyWith<Block_Heading> get copyWith => _$Block_HeadingCopyWithImpl<Block_Heading>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Block_Heading&&(identical(other.level, level) || other.level == level)&&const DeepCollectionEquality().equals(other.inlines, _inlines));
}


@override
int get hashCode {
    return Object.hash(runtimeType,level,const DeepCollectionEquality().hash(_inlines));
}

@override
String toString() {
    return 'Block.heading(level: $level, inlines: $inlines)';
}


}

/// @nodoc
abstract mixin class $Block_HeadingCopyWith<$Res> implements $BlockCopyWith<$Res> {
  factory $Block_HeadingCopyWith(Block_Heading value, $Res Function(Block_Heading) _then) = _$Block_HeadingCopyWithImpl;
@useResult
$Res call({
 int level, List<Inline> inlines
});




}
/// @nodoc
class _$Block_HeadingCopyWithImpl<$Res>
    implements $Block_HeadingCopyWith<$Res> {
  _$Block_HeadingCopyWithImpl(this._self, this._then);

  final Block_Heading _self;
  final $Res Function(Block_Heading) _then;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? level = null,Object? inlines = null,}) {
  return _then(Block_Heading(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,inlines: null == inlines ? _self._inlines : inlines // ignore: cast_nullable_to_non_nullable
as List<Inline>,
  ));
}


}

/// @nodoc


class Block_Paragraph extends Block {
  const Block_Paragraph({required  List<Inline> inlines}): _inlines = inlines,super._();
  

 final  List<Inline> _inlines;
 List<Inline> get inlines {
  if (_inlines is EqualUnmodifiableListView) return _inlines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_inlines);
}


/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Block_ParagraphCopyWith<Block_Paragraph> get copyWith => _$Block_ParagraphCopyWithImpl<Block_Paragraph>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Block_Paragraph&&const DeepCollectionEquality().equals(other.inlines, _inlines));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_inlines));
}

@override
String toString() {
    return 'Block.paragraph(inlines: $inlines)';
}


}

/// @nodoc
abstract mixin class $Block_ParagraphCopyWith<$Res> implements $BlockCopyWith<$Res> {
  factory $Block_ParagraphCopyWith(Block_Paragraph value, $Res Function(Block_Paragraph) _then) = _$Block_ParagraphCopyWithImpl;
@useResult
$Res call({
 List<Inline> inlines
});




}
/// @nodoc
class _$Block_ParagraphCopyWithImpl<$Res>
    implements $Block_ParagraphCopyWith<$Res> {
  _$Block_ParagraphCopyWithImpl(this._self, this._then);

  final Block_Paragraph _self;
  final $Res Function(Block_Paragraph) _then;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? inlines = null,}) {
  return _then(Block_Paragraph(
inlines: null == inlines ? _self._inlines : inlines // ignore: cast_nullable_to_non_nullable
as List<Inline>,
  ));
}


}

/// @nodoc


class Block_ListItem extends Block {
  const Block_ListItem({required this.marker, required this.depth, required  List<Inline> inlines}): _inlines = inlines,super._();
  

 final  ListMarker marker;
 final  int depth;
 final  List<Inline> _inlines;
 List<Inline> get inlines {
  if (_inlines is EqualUnmodifiableListView) return _inlines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_inlines);
}


/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Block_ListItemCopyWith<Block_ListItem> get copyWith => _$Block_ListItemCopyWithImpl<Block_ListItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Block_ListItem&&(identical(other.marker, marker) || other.marker == marker)&&(identical(other.depth, depth) || other.depth == depth)&&const DeepCollectionEquality().equals(other.inlines, _inlines));
}


@override
int get hashCode {
    return Object.hash(runtimeType,marker,depth,const DeepCollectionEquality().hash(_inlines));
}

@override
String toString() {
    return 'Block.listItem(marker: $marker, depth: $depth, inlines: $inlines)';
}


}

/// @nodoc
abstract mixin class $Block_ListItemCopyWith<$Res> implements $BlockCopyWith<$Res> {
  factory $Block_ListItemCopyWith(Block_ListItem value, $Res Function(Block_ListItem) _then) = _$Block_ListItemCopyWithImpl;
@useResult
$Res call({
 ListMarker marker, int depth, List<Inline> inlines
});


$ListMarkerCopyWith<$Res> get marker;

}
/// @nodoc
class _$Block_ListItemCopyWithImpl<$Res>
    implements $Block_ListItemCopyWith<$Res> {
  _$Block_ListItemCopyWithImpl(this._self, this._then);

  final Block_ListItem _self;
  final $Res Function(Block_ListItem) _then;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? marker = null,Object? depth = null,Object? inlines = null,}) {
  return _then(Block_ListItem(
marker: null == marker ? _self.marker : marker // ignore: cast_nullable_to_non_nullable
as ListMarker,depth: null == depth ? _self.depth : depth // ignore: cast_nullable_to_non_nullable
as int,inlines: null == inlines ? _self._inlines : inlines // ignore: cast_nullable_to_non_nullable
as List<Inline>,
  ));
}

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListMarkerCopyWith<$Res> get marker {
  
  return $ListMarkerCopyWith<$Res>(_self.marker, (value) {
    return _then(_self.copyWith(marker: value));
  });
}
}

/// @nodoc


class Block_Quote extends Block {
  const Block_Quote({required  List<BlockNode> blocks}): _blocks = blocks,super._();
  

 final  List<BlockNode> _blocks;
 List<BlockNode> get blocks {
  if (_blocks is EqualUnmodifiableListView) return _blocks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blocks);
}


/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Block_QuoteCopyWith<Block_Quote> get copyWith => _$Block_QuoteCopyWithImpl<Block_Quote>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Block_Quote&&const DeepCollectionEquality().equals(other.blocks, _blocks));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_blocks));
}

@override
String toString() {
    return 'Block.quote(blocks: $blocks)';
}


}

/// @nodoc
abstract mixin class $Block_QuoteCopyWith<$Res> implements $BlockCopyWith<$Res> {
  factory $Block_QuoteCopyWith(Block_Quote value, $Res Function(Block_Quote) _then) = _$Block_QuoteCopyWithImpl;
@useResult
$Res call({
 List<BlockNode> blocks
});




}
/// @nodoc
class _$Block_QuoteCopyWithImpl<$Res>
    implements $Block_QuoteCopyWith<$Res> {
  _$Block_QuoteCopyWithImpl(this._self, this._then);

  final Block_Quote _self;
  final $Res Function(Block_Quote) _then;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? blocks = null,}) {
  return _then(Block_Quote(
blocks: null == blocks ? _self._blocks : blocks // ignore: cast_nullable_to_non_nullable
as List<BlockNode>,
  ));
}


}

/// @nodoc


class Block_Code extends Block {
  const Block_Code({required  List<String> lines}): _lines = lines,super._();
  

 final  List<String> _lines;
 List<String> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}


/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Block_CodeCopyWith<Block_Code> get copyWith => _$Block_CodeCopyWithImpl<Block_Code>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Block_Code&&const DeepCollectionEquality().equals(other.lines, _lines));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_lines));
}

@override
String toString() {
    return 'Block.code(lines: $lines)';
}


}

/// @nodoc
abstract mixin class $Block_CodeCopyWith<$Res> implements $BlockCopyWith<$Res> {
  factory $Block_CodeCopyWith(Block_Code value, $Res Function(Block_Code) _then) = _$Block_CodeCopyWithImpl;
@useResult
$Res call({
 List<String> lines
});




}
/// @nodoc
class _$Block_CodeCopyWithImpl<$Res>
    implements $Block_CodeCopyWith<$Res> {
  _$Block_CodeCopyWithImpl(this._self, this._then);

  final Block_Code _self;
  final $Res Function(Block_Code) _then;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? lines = null,}) {
  return _then(Block_Code(
lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class Block_Figure extends Block {
  const Block_Figure({required this.image, required  List<Inline> caption}): _caption = caption,super._();
  

 final  ResourceId image;
 final  List<Inline> _caption;
 List<Inline> get caption {
  if (_caption is EqualUnmodifiableListView) return _caption;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_caption);
}


/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Block_FigureCopyWith<Block_Figure> get copyWith => _$Block_FigureCopyWithImpl<Block_Figure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Block_Figure&&(identical(other.image, image) || other.image == image)&&const DeepCollectionEquality().equals(other.caption, _caption));
}


@override
int get hashCode {
    return Object.hash(runtimeType,image,const DeepCollectionEquality().hash(_caption));
}

@override
String toString() {
    return 'Block.figure(image: $image, caption: $caption)';
}


}

/// @nodoc
abstract mixin class $Block_FigureCopyWith<$Res> implements $BlockCopyWith<$Res> {
  factory $Block_FigureCopyWith(Block_Figure value, $Res Function(Block_Figure) _then) = _$Block_FigureCopyWithImpl;
@useResult
$Res call({
 ResourceId image, List<Inline> caption
});




}
/// @nodoc
class _$Block_FigureCopyWithImpl<$Res>
    implements $Block_FigureCopyWith<$Res> {
  _$Block_FigureCopyWithImpl(this._self, this._then);

  final Block_Figure _self;
  final $Res Function(Block_Figure) _then;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? image = null,Object? caption = null,}) {
  return _then(Block_Figure(
image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as ResourceId,caption: null == caption ? _self._caption : caption // ignore: cast_nullable_to_non_nullable
as List<Inline>,
  ));
}


}

/// @nodoc


class Block_Formula extends Block {
  const Block_Formula({required this.image}): super._();
  

 final  ResourceId image;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Block_FormulaCopyWith<Block_Formula> get copyWith => _$Block_FormulaCopyWithImpl<Block_Formula>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Block_Formula&&(identical(other.image, image) || other.image == image));
}


@override
int get hashCode {
    return Object.hash(runtimeType,image);
}

@override
String toString() {
    return 'Block.formula(image: $image)';
}


}

/// @nodoc
abstract mixin class $Block_FormulaCopyWith<$Res> implements $BlockCopyWith<$Res> {
  factory $Block_FormulaCopyWith(Block_Formula value, $Res Function(Block_Formula) _then) = _$Block_FormulaCopyWithImpl;
@useResult
$Res call({
 ResourceId image
});




}
/// @nodoc
class _$Block_FormulaCopyWithImpl<$Res>
    implements $Block_FormulaCopyWith<$Res> {
  _$Block_FormulaCopyWithImpl(this._self, this._then);

  final Block_Formula _self;
  final $Res Function(Block_Formula) _then;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? image = null,}) {
  return _then(Block_Formula(
image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as ResourceId,
  ));
}


}

/// @nodoc


class Block_Table extends Block {
  const Block_Table(this.field0): super._();
  

 final  Table field0;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Block_TableCopyWith<Block_Table> get copyWith => _$Block_TableCopyWithImpl<Block_Table>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Block_Table&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode {
    return Object.hash(runtimeType,field0);
}

@override
String toString() {
    return 'Block.table(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $Block_TableCopyWith<$Res> implements $BlockCopyWith<$Res> {
  factory $Block_TableCopyWith(Block_Table value, $Res Function(Block_Table) _then) = _$Block_TableCopyWithImpl;
@useResult
$Res call({
 Table field0
});




}
/// @nodoc
class _$Block_TableCopyWithImpl<$Res>
    implements $Block_TableCopyWith<$Res> {
  _$Block_TableCopyWithImpl(this._self, this._then);

  final Block_Table _self;
  final $Res Function(Block_Table) _then;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(Block_Table(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as Table,
  ));
}


}

/// @nodoc


class Block_Footnote extends Block {
  const Block_Footnote({required this.id, required  List<BlockNode> blocks}): _blocks = blocks,super._();
  

 final  String id;
 final  List<BlockNode> _blocks;
 List<BlockNode> get blocks {
  if (_blocks is EqualUnmodifiableListView) return _blocks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blocks);
}


/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Block_FootnoteCopyWith<Block_Footnote> get copyWith => _$Block_FootnoteCopyWithImpl<Block_Footnote>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Block_Footnote&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.blocks, _blocks));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_blocks));
}

@override
String toString() {
    return 'Block.footnote(id: $id, blocks: $blocks)';
}


}

/// @nodoc
abstract mixin class $Block_FootnoteCopyWith<$Res> implements $BlockCopyWith<$Res> {
  factory $Block_FootnoteCopyWith(Block_Footnote value, $Res Function(Block_Footnote) _then) = _$Block_FootnoteCopyWithImpl;
@useResult
$Res call({
 String id, List<BlockNode> blocks
});




}
/// @nodoc
class _$Block_FootnoteCopyWithImpl<$Res>
    implements $Block_FootnoteCopyWith<$Res> {
  _$Block_FootnoteCopyWithImpl(this._self, this._then);

  final Block_Footnote _self;
  final $Res Function(Block_Footnote) _then;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,Object? blocks = null,}) {
  return _then(Block_Footnote(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,blocks: null == blocks ? _self._blocks : blocks // ignore: cast_nullable_to_non_nullable
as List<BlockNode>,
  ));
}


}

/// @nodoc


class Block_Separator extends Block {
  const Block_Separator(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Block_Separator);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'Block.separator()';
}


}




/// @nodoc


class Block_FixedPage extends Block {
  const Block_FixedPage({required this.image}): super._();
  

 final  ResourceId image;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Block_FixedPageCopyWith<Block_FixedPage> get copyWith => _$Block_FixedPageCopyWithImpl<Block_FixedPage>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Block_FixedPage&&(identical(other.image, image) || other.image == image));
}


@override
int get hashCode {
    return Object.hash(runtimeType,image);
}

@override
String toString() {
    return 'Block.fixedPage(image: $image)';
}


}

/// @nodoc
abstract mixin class $Block_FixedPageCopyWith<$Res> implements $BlockCopyWith<$Res> {
  factory $Block_FixedPageCopyWith(Block_FixedPage value, $Res Function(Block_FixedPage) _then) = _$Block_FixedPageCopyWithImpl;
@useResult
$Res call({
 ResourceId image
});




}
/// @nodoc
class _$Block_FixedPageCopyWithImpl<$Res>
    implements $Block_FixedPageCopyWith<$Res> {
  _$Block_FixedPageCopyWithImpl(this._self, this._then);

  final Block_FixedPage _self;
  final $Res Function(Block_FixedPage) _then;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? image = null,}) {
  return _then(Block_FixedPage(
image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as ResourceId,
  ));
}


}

/// @nodoc
mixin _$FormatError {

 Object get field0;



@override
bool operator ==(Object other) {
  final _this = this as FormatError;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FormatError&&const DeepCollectionEquality().equals(other.field0, _this.field0));
}


@override
int get hashCode {
  final _this = this as FormatError;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.field0));
}

@override
String toString() {
  final _this = this as FormatError;
  return 'FormatError(field0: ${_this.field0})';
}


}

/// @nodoc
class $FormatErrorCopyWith<$Res>  {
$FormatErrorCopyWith(FormatError _, $Res Function(FormatError) __);
}


/// Adds pattern-matching-related methods to [FormatError].
extension FormatErrorPatterns on FormatError {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( FormatError_UnsupportedFormatVersion value)?  unsupportedFormatVersion,TResult Function( FormatError_Corrupt value)?  corrupt,TResult Function( FormatError_Encode value)?  encode,required TResult orElse(),}){
final _that = this;
switch (_that) {
case FormatError_UnsupportedFormatVersion() when unsupportedFormatVersion != null:
return unsupportedFormatVersion(_that);case FormatError_Corrupt() when corrupt != null:
return corrupt(_that);case FormatError_Encode() when encode != null:
return encode(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( FormatError_UnsupportedFormatVersion value)  unsupportedFormatVersion,required TResult Function( FormatError_Corrupt value)  corrupt,required TResult Function( FormatError_Encode value)  encode,}){
final _that = this;
switch (_that) {
case FormatError_UnsupportedFormatVersion():
return unsupportedFormatVersion(_that);case FormatError_Corrupt():
return corrupt(_that);case FormatError_Encode():
return encode(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( FormatError_UnsupportedFormatVersion value)?  unsupportedFormatVersion,TResult? Function( FormatError_Corrupt value)?  corrupt,TResult? Function( FormatError_Encode value)?  encode,}){
final _that = this;
switch (_that) {
case FormatError_UnsupportedFormatVersion() when unsupportedFormatVersion != null:
return unsupportedFormatVersion(_that);case FormatError_Corrupt() when corrupt != null:
return corrupt(_that);case FormatError_Encode() when encode != null:
return encode(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int field0)?  unsupportedFormatVersion,TResult Function( String field0)?  corrupt,TResult Function( String field0)?  encode,required TResult orElse(),}) {final _that = this;
switch (_that) {
case FormatError_UnsupportedFormatVersion() when unsupportedFormatVersion != null:
return unsupportedFormatVersion(_that.field0);case FormatError_Corrupt() when corrupt != null:
return corrupt(_that.field0);case FormatError_Encode() when encode != null:
return encode(_that.field0);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int field0)  unsupportedFormatVersion,required TResult Function( String field0)  corrupt,required TResult Function( String field0)  encode,}) {final _that = this;
switch (_that) {
case FormatError_UnsupportedFormatVersion():
return unsupportedFormatVersion(_that.field0);case FormatError_Corrupt():
return corrupt(_that.field0);case FormatError_Encode():
return encode(_that.field0);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int field0)?  unsupportedFormatVersion,TResult? Function( String field0)?  corrupt,TResult? Function( String field0)?  encode,}) {final _that = this;
switch (_that) {
case FormatError_UnsupportedFormatVersion() when unsupportedFormatVersion != null:
return unsupportedFormatVersion(_that.field0);case FormatError_Corrupt() when corrupt != null:
return corrupt(_that.field0);case FormatError_Encode() when encode != null:
return encode(_that.field0);case _:
  return null;

}
}

}

/// @nodoc


class FormatError_UnsupportedFormatVersion extends FormatError {
  const FormatError_UnsupportedFormatVersion(this.field0): super._();
  

@override final  int field0;

/// Create a copy of FormatError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FormatError_UnsupportedFormatVersionCopyWith<FormatError_UnsupportedFormatVersion> get copyWith => _$FormatError_UnsupportedFormatVersionCopyWithImpl<FormatError_UnsupportedFormatVersion>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FormatError_UnsupportedFormatVersion&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode {
    return Object.hash(runtimeType,field0);
}

@override
String toString() {
    return 'FormatError.unsupportedFormatVersion(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $FormatError_UnsupportedFormatVersionCopyWith<$Res> implements $FormatErrorCopyWith<$Res> {
  factory $FormatError_UnsupportedFormatVersionCopyWith(FormatError_UnsupportedFormatVersion value, $Res Function(FormatError_UnsupportedFormatVersion) _then) = _$FormatError_UnsupportedFormatVersionCopyWithImpl;
@useResult
$Res call({
 int field0
});




}
/// @nodoc
class _$FormatError_UnsupportedFormatVersionCopyWithImpl<$Res>
    implements $FormatError_UnsupportedFormatVersionCopyWith<$Res> {
  _$FormatError_UnsupportedFormatVersionCopyWithImpl(this._self, this._then);

  final FormatError_UnsupportedFormatVersion _self;
  final $Res Function(FormatError_UnsupportedFormatVersion) _then;

/// Create a copy of FormatError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(FormatError_UnsupportedFormatVersion(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class FormatError_Corrupt extends FormatError {
  const FormatError_Corrupt(this.field0): super._();
  

@override final  String field0;

/// Create a copy of FormatError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FormatError_CorruptCopyWith<FormatError_Corrupt> get copyWith => _$FormatError_CorruptCopyWithImpl<FormatError_Corrupt>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FormatError_Corrupt&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode {
    return Object.hash(runtimeType,field0);
}

@override
String toString() {
    return 'FormatError.corrupt(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $FormatError_CorruptCopyWith<$Res> implements $FormatErrorCopyWith<$Res> {
  factory $FormatError_CorruptCopyWith(FormatError_Corrupt value, $Res Function(FormatError_Corrupt) _then) = _$FormatError_CorruptCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$FormatError_CorruptCopyWithImpl<$Res>
    implements $FormatError_CorruptCopyWith<$Res> {
  _$FormatError_CorruptCopyWithImpl(this._self, this._then);

  final FormatError_Corrupt _self;
  final $Res Function(FormatError_Corrupt) _then;

/// Create a copy of FormatError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(FormatError_Corrupt(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class FormatError_Encode extends FormatError {
  const FormatError_Encode(this.field0): super._();
  

@override final  String field0;

/// Create a copy of FormatError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FormatError_EncodeCopyWith<FormatError_Encode> get copyWith => _$FormatError_EncodeCopyWithImpl<FormatError_Encode>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FormatError_Encode&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode {
    return Object.hash(runtimeType,field0);
}

@override
String toString() {
    return 'FormatError.encode(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $FormatError_EncodeCopyWith<$Res> implements $FormatErrorCopyWith<$Res> {
  factory $FormatError_EncodeCopyWith(FormatError_Encode value, $Res Function(FormatError_Encode) _then) = _$FormatError_EncodeCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$FormatError_EncodeCopyWithImpl<$Res>
    implements $FormatError_EncodeCopyWith<$Res> {
  _$FormatError_EncodeCopyWithImpl(this._self, this._then);

  final FormatError_Encode _self;
  final $Res Function(FormatError_Encode) _then;

/// Create a copy of FormatError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(FormatError_Encode(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$Inline {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Inline);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'Inline()';
}


}

/// @nodoc
class $InlineCopyWith<$Res>  {
$InlineCopyWith(Inline _, $Res Function(Inline) __);
}


/// Adds pattern-matching-related methods to [Inline].
extension InlinePatterns on Inline {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Inline_Text value)?  text,TResult Function( Inline_Link value)?  link,TResult Function( Inline_NoteRef value)?  noteRef,TResult Function( Inline_Image value)?  image,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Inline_Text() when text != null:
return text(_that);case Inline_Link() when link != null:
return link(_that);case Inline_NoteRef() when noteRef != null:
return noteRef(_that);case Inline_Image() when image != null:
return image(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Inline_Text value)  text,required TResult Function( Inline_Link value)  link,required TResult Function( Inline_NoteRef value)  noteRef,required TResult Function( Inline_Image value)  image,}){
final _that = this;
switch (_that) {
case Inline_Text():
return text(_that);case Inline_Link():
return link(_that);case Inline_NoteRef():
return noteRef(_that);case Inline_Image():
return image(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Inline_Text value)?  text,TResult? Function( Inline_Link value)?  link,TResult? Function( Inline_NoteRef value)?  noteRef,TResult? Function( Inline_Image value)?  image,}){
final _that = this;
switch (_that) {
case Inline_Text() when text != null:
return text(_that);case Inline_Link() when link != null:
return link(_that);case Inline_NoteRef() when noteRef != null:
return noteRef(_that);case Inline_Image() when image != null:
return image(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String text,  Style style)?  text,TResult Function( LinkTarget target,  List<Inline> inlines)?  link,TResult Function( String id,  String label)?  noteRef,TResult Function( ResourceId res,  double heightEm)?  image,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Inline_Text() when text != null:
return text(_that.text,_that.style);case Inline_Link() when link != null:
return link(_that.target,_that.inlines);case Inline_NoteRef() when noteRef != null:
return noteRef(_that.id,_that.label);case Inline_Image() when image != null:
return image(_that.res,_that.heightEm);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String text,  Style style)  text,required TResult Function( LinkTarget target,  List<Inline> inlines)  link,required TResult Function( String id,  String label)  noteRef,required TResult Function( ResourceId res,  double heightEm)  image,}) {final _that = this;
switch (_that) {
case Inline_Text():
return text(_that.text,_that.style);case Inline_Link():
return link(_that.target,_that.inlines);case Inline_NoteRef():
return noteRef(_that.id,_that.label);case Inline_Image():
return image(_that.res,_that.heightEm);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String text,  Style style)?  text,TResult? Function( LinkTarget target,  List<Inline> inlines)?  link,TResult? Function( String id,  String label)?  noteRef,TResult? Function( ResourceId res,  double heightEm)?  image,}) {final _that = this;
switch (_that) {
case Inline_Text() when text != null:
return text(_that.text,_that.style);case Inline_Link() when link != null:
return link(_that.target,_that.inlines);case Inline_NoteRef() when noteRef != null:
return noteRef(_that.id,_that.label);case Inline_Image() when image != null:
return image(_that.res,_that.heightEm);case _:
  return null;

}
}

}

/// @nodoc


class Inline_Text extends Inline {
  const Inline_Text({required this.text, required this.style}): super._();
  

 final  String text;
 final  Style style;

/// Create a copy of Inline
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Inline_TextCopyWith<Inline_Text> get copyWith => _$Inline_TextCopyWithImpl<Inline_Text>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Inline_Text&&(identical(other.text, text) || other.text == text)&&(identical(other.style, style) || other.style == style));
}


@override
int get hashCode {
    return Object.hash(runtimeType,text,style);
}

@override
String toString() {
    return 'Inline.text(text: $text, style: $style)';
}


}

/// @nodoc
abstract mixin class $Inline_TextCopyWith<$Res> implements $InlineCopyWith<$Res> {
  factory $Inline_TextCopyWith(Inline_Text value, $Res Function(Inline_Text) _then) = _$Inline_TextCopyWithImpl;
@useResult
$Res call({
 String text, Style style
});




}
/// @nodoc
class _$Inline_TextCopyWithImpl<$Res>
    implements $Inline_TextCopyWith<$Res> {
  _$Inline_TextCopyWithImpl(this._self, this._then);

  final Inline_Text _self;
  final $Res Function(Inline_Text) _then;

/// Create a copy of Inline
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? text = null,Object? style = null,}) {
  return _then(Inline_Text(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,style: null == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as Style,
  ));
}


}

/// @nodoc


class Inline_Link extends Inline {
  const Inline_Link({required this.target, required  List<Inline> inlines}): _inlines = inlines,super._();
  

 final  LinkTarget target;
 final  List<Inline> _inlines;
 List<Inline> get inlines {
  if (_inlines is EqualUnmodifiableListView) return _inlines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_inlines);
}


/// Create a copy of Inline
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Inline_LinkCopyWith<Inline_Link> get copyWith => _$Inline_LinkCopyWithImpl<Inline_Link>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Inline_Link&&(identical(other.target, target) || other.target == target)&&const DeepCollectionEquality().equals(other.inlines, _inlines));
}


@override
int get hashCode {
    return Object.hash(runtimeType,target,const DeepCollectionEquality().hash(_inlines));
}

@override
String toString() {
    return 'Inline.link(target: $target, inlines: $inlines)';
}


}

/// @nodoc
abstract mixin class $Inline_LinkCopyWith<$Res> implements $InlineCopyWith<$Res> {
  factory $Inline_LinkCopyWith(Inline_Link value, $Res Function(Inline_Link) _then) = _$Inline_LinkCopyWithImpl;
@useResult
$Res call({
 LinkTarget target, List<Inline> inlines
});


$LinkTargetCopyWith<$Res> get target;

}
/// @nodoc
class _$Inline_LinkCopyWithImpl<$Res>
    implements $Inline_LinkCopyWith<$Res> {
  _$Inline_LinkCopyWithImpl(this._self, this._then);

  final Inline_Link _self;
  final $Res Function(Inline_Link) _then;

/// Create a copy of Inline
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? target = null,Object? inlines = null,}) {
  return _then(Inline_Link(
target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as LinkTarget,inlines: null == inlines ? _self._inlines : inlines // ignore: cast_nullable_to_non_nullable
as List<Inline>,
  ));
}

/// Create a copy of Inline
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LinkTargetCopyWith<$Res> get target {
  
  return $LinkTargetCopyWith<$Res>(_self.target, (value) {
    return _then(_self.copyWith(target: value));
  });
}
}

/// @nodoc


class Inline_NoteRef extends Inline {
  const Inline_NoteRef({required this.id, required this.label}): super._();
  

 final  String id;
 final  String label;

/// Create a copy of Inline
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Inline_NoteRefCopyWith<Inline_NoteRef> get copyWith => _$Inline_NoteRefCopyWithImpl<Inline_NoteRef>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Inline_NoteRef&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,label);
}

@override
String toString() {
    return 'Inline.noteRef(id: $id, label: $label)';
}


}

/// @nodoc
abstract mixin class $Inline_NoteRefCopyWith<$Res> implements $InlineCopyWith<$Res> {
  factory $Inline_NoteRefCopyWith(Inline_NoteRef value, $Res Function(Inline_NoteRef) _then) = _$Inline_NoteRefCopyWithImpl;
@useResult
$Res call({
 String id, String label
});




}
/// @nodoc
class _$Inline_NoteRefCopyWithImpl<$Res>
    implements $Inline_NoteRefCopyWith<$Res> {
  _$Inline_NoteRefCopyWithImpl(this._self, this._then);

  final Inline_NoteRef _self;
  final $Res Function(Inline_NoteRef) _then;

/// Create a copy of Inline
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,}) {
  return _then(Inline_NoteRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class Inline_Image extends Inline {
  const Inline_Image({required this.res, required this.heightEm}): super._();
  

 final  ResourceId res;
 final  double heightEm;

/// Create a copy of Inline
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Inline_ImageCopyWith<Inline_Image> get copyWith => _$Inline_ImageCopyWithImpl<Inline_Image>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Inline_Image&&(identical(other.res, res) || other.res == res)&&(identical(other.heightEm, heightEm) || other.heightEm == heightEm));
}


@override
int get hashCode {
    return Object.hash(runtimeType,res,heightEm);
}

@override
String toString() {
    return 'Inline.image(res: $res, heightEm: $heightEm)';
}


}

/// @nodoc
abstract mixin class $Inline_ImageCopyWith<$Res> implements $InlineCopyWith<$Res> {
  factory $Inline_ImageCopyWith(Inline_Image value, $Res Function(Inline_Image) _then) = _$Inline_ImageCopyWithImpl;
@useResult
$Res call({
 ResourceId res, double heightEm
});




}
/// @nodoc
class _$Inline_ImageCopyWithImpl<$Res>
    implements $Inline_ImageCopyWith<$Res> {
  _$Inline_ImageCopyWithImpl(this._self, this._then);

  final Inline_Image _self;
  final $Res Function(Inline_Image) _then;

/// Create a copy of Inline
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? res = null,Object? heightEm = null,}) {
  return _then(Inline_Image(
res: null == res ? _self.res : res // ignore: cast_nullable_to_non_nullable
as ResourceId,heightEm: null == heightEm ? _self.heightEm : heightEm // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$LinkTarget {

 Object get field0;



@override
bool operator ==(Object other) {
  final _this = this as LinkTarget;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LinkTarget&&const DeepCollectionEquality().equals(other.field0, _this.field0));
}


@override
int get hashCode {
  final _this = this as LinkTarget;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.field0));
}

@override
String toString() {
  final _this = this as LinkTarget;
  return 'LinkTarget(field0: ${_this.field0})';
}


}

/// @nodoc
class $LinkTargetCopyWith<$Res>  {
$LinkTargetCopyWith(LinkTarget _, $Res Function(LinkTarget) __);
}


/// Adds pattern-matching-related methods to [LinkTarget].
extension LinkTargetPatterns on LinkTarget {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LinkTarget_Internal value)?  internal,TResult Function( LinkTarget_External value)?  external_,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LinkTarget_Internal() when internal != null:
return internal(_that);case LinkTarget_External() when external_ != null:
return external_(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LinkTarget_Internal value)  internal,required TResult Function( LinkTarget_External value)  external_,}){
final _that = this;
switch (_that) {
case LinkTarget_Internal():
return internal(_that);case LinkTarget_External():
return external_(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LinkTarget_Internal value)?  internal,TResult? Function( LinkTarget_External value)?  external_,}){
final _that = this;
switch (_that) {
case LinkTarget_Internal() when internal != null:
return internal(_that);case LinkTarget_External() when external_ != null:
return external_(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( BigInt field0)?  internal,TResult Function( String field0)?  external_,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LinkTarget_Internal() when internal != null:
return internal(_that.field0);case LinkTarget_External() when external_ != null:
return external_(_that.field0);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( BigInt field0)  internal,required TResult Function( String field0)  external_,}) {final _that = this;
switch (_that) {
case LinkTarget_Internal():
return internal(_that.field0);case LinkTarget_External():
return external_(_that.field0);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( BigInt field0)?  internal,TResult? Function( String field0)?  external_,}) {final _that = this;
switch (_that) {
case LinkTarget_Internal() when internal != null:
return internal(_that.field0);case LinkTarget_External() when external_ != null:
return external_(_that.field0);case _:
  return null;

}
}

}

/// @nodoc


class LinkTarget_Internal extends LinkTarget {
  const LinkTarget_Internal(this.field0): super._();
  

@override final  BigInt field0;

/// Create a copy of LinkTarget
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LinkTarget_InternalCopyWith<LinkTarget_Internal> get copyWith => _$LinkTarget_InternalCopyWithImpl<LinkTarget_Internal>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LinkTarget_Internal&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode {
    return Object.hash(runtimeType,field0);
}

@override
String toString() {
    return 'LinkTarget.internal(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $LinkTarget_InternalCopyWith<$Res> implements $LinkTargetCopyWith<$Res> {
  factory $LinkTarget_InternalCopyWith(LinkTarget_Internal value, $Res Function(LinkTarget_Internal) _then) = _$LinkTarget_InternalCopyWithImpl;
@useResult
$Res call({
 BigInt field0
});




}
/// @nodoc
class _$LinkTarget_InternalCopyWithImpl<$Res>
    implements $LinkTarget_InternalCopyWith<$Res> {
  _$LinkTarget_InternalCopyWithImpl(this._self, this._then);

  final LinkTarget_Internal _self;
  final $Res Function(LinkTarget_Internal) _then;

/// Create a copy of LinkTarget
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(LinkTarget_Internal(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as BigInt,
  ));
}


}

/// @nodoc


class LinkTarget_External extends LinkTarget {
  const LinkTarget_External(this.field0): super._();
  

@override final  String field0;

/// Create a copy of LinkTarget
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LinkTarget_ExternalCopyWith<LinkTarget_External> get copyWith => _$LinkTarget_ExternalCopyWithImpl<LinkTarget_External>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LinkTarget_External&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode {
    return Object.hash(runtimeType,field0);
}

@override
String toString() {
    return 'LinkTarget.external_(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $LinkTarget_ExternalCopyWith<$Res> implements $LinkTargetCopyWith<$Res> {
  factory $LinkTarget_ExternalCopyWith(LinkTarget_External value, $Res Function(LinkTarget_External) _then) = _$LinkTarget_ExternalCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$LinkTarget_ExternalCopyWithImpl<$Res>
    implements $LinkTarget_ExternalCopyWith<$Res> {
  _$LinkTarget_ExternalCopyWithImpl(this._self, this._then);

  final LinkTarget_External _self;
  final $Res Function(LinkTarget_External) _then;

/// Create a copy of LinkTarget
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(LinkTarget_External(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ListMarker {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ListMarker);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ListMarker()';
}


}

/// @nodoc
class $ListMarkerCopyWith<$Res>  {
$ListMarkerCopyWith(ListMarker _, $Res Function(ListMarker) __);
}


/// Adds pattern-matching-related methods to [ListMarker].
extension ListMarkerPatterns on ListMarker {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ListMarker_Bullet value)?  bullet,TResult Function( ListMarker_Number value)?  number,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ListMarker_Bullet() when bullet != null:
return bullet(_that);case ListMarker_Number() when number != null:
return number(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ListMarker_Bullet value)  bullet,required TResult Function( ListMarker_Number value)  number,}){
final _that = this;
switch (_that) {
case ListMarker_Bullet():
return bullet(_that);case ListMarker_Number():
return number(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ListMarker_Bullet value)?  bullet,TResult? Function( ListMarker_Number value)?  number,}){
final _that = this;
switch (_that) {
case ListMarker_Bullet() when bullet != null:
return bullet(_that);case ListMarker_Number() when number != null:
return number(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  bullet,TResult Function( int field0)?  number,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ListMarker_Bullet() when bullet != null:
return bullet();case ListMarker_Number() when number != null:
return number(_that.field0);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  bullet,required TResult Function( int field0)  number,}) {final _that = this;
switch (_that) {
case ListMarker_Bullet():
return bullet();case ListMarker_Number():
return number(_that.field0);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  bullet,TResult? Function( int field0)?  number,}) {final _that = this;
switch (_that) {
case ListMarker_Bullet() when bullet != null:
return bullet();case ListMarker_Number() when number != null:
return number(_that.field0);case _:
  return null;

}
}

}

/// @nodoc


class ListMarker_Bullet extends ListMarker {
  const ListMarker_Bullet(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ListMarker_Bullet);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ListMarker.bullet()';
}


}




/// @nodoc


class ListMarker_Number extends ListMarker {
  const ListMarker_Number(this.field0): super._();
  

 final  int field0;

/// Create a copy of ListMarker
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListMarker_NumberCopyWith<ListMarker_Number> get copyWith => _$ListMarker_NumberCopyWithImpl<ListMarker_Number>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ListMarker_Number&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode {
    return Object.hash(runtimeType,field0);
}

@override
String toString() {
    return 'ListMarker.number(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $ListMarker_NumberCopyWith<$Res> implements $ListMarkerCopyWith<$Res> {
  factory $ListMarker_NumberCopyWith(ListMarker_Number value, $Res Function(ListMarker_Number) _then) = _$ListMarker_NumberCopyWithImpl;
@useResult
$Res call({
 int field0
});




}
/// @nodoc
class _$ListMarker_NumberCopyWithImpl<$Res>
    implements $ListMarker_NumberCopyWith<$Res> {
  _$ListMarker_NumberCopyWithImpl(this._self, this._then);

  final ListMarker_Number _self;
  final $Res Function(ListMarker_Number) _then;

/// Create a copy of ListMarker
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(ListMarker_Number(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
