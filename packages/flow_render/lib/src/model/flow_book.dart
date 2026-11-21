import 'package:flow_render/src/model/flow_block.dart';
import 'package:flutter/foundation.dart';

/// A chapter: [blocks] with an optional [title].
@immutable
class FlowSection {
  const new(this.blocks, {this.title});

  final String? title;
  final List<FlowBlock> blocks;

  /// Sum of the block lengths: the size of the chapter text.
  int get length => blocks.fold(0, (sum, block) => sum + block.length);

  @override
  bool operator ==(Object other) =>
      other is FlowSection &&
      title == other.title &&
      listEquals(blocks, other.blocks);

  @override
  int get hashCode => Object.hash(title, Object.hashAll(blocks));
}

/// A book split into [sections] (never empty).
@immutable
class FlowBook {
  const new(this.title, this.sections);

  final String title;
  final List<FlowSection> sections;

  @override
  bool operator ==(Object other) =>
      other is FlowBook &&
      title == other.title &&
      listEquals(sections, other.sections);

  @override
  int get hashCode => Object.hash(title, Object.hashAll(sections));
}
