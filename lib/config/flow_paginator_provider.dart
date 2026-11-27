import 'package:flow_render/flow_render.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'flow_paginator_provider.g.dart';

/// Splits chapters into pages (replaceable in tests).
@Riverpod(keepAlive: true)
FlowPaginator flowPaginator(Ref ref) => const FlowPaginator();
