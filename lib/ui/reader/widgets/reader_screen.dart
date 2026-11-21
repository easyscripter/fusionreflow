import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show DisplayFeatureType;

import 'package:flow_render/flow_render.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fusionreflow/data/repositories/book_exceptions.dart';
import 'package:fusionreflow/l10n/app_localizations.dart';
import 'package:fusionreflow/routing/app_routes.dart';
import 'package:fusionreflow/ui/core/theme/reader_palette.dart';
import 'package:fusionreflow/ui/reader/reader_page_metrics.dart';
import 'package:fusionreflow/ui/reader/view_models/reader_state.dart';
import 'package:fusionreflow/ui/reader/view_models/reader_view_model.dart';
import 'package:fusionreflow/ui/reader/widgets/reader_footer.dart';
import 'package:fusionreflow/ui/reader/widgets/reader_header.dart';
import 'package:fusionreflow/ui/reader/widgets/reader_loading_view.dart';
import 'package:fusionreflow/ui/reader/widgets/reader_message_view.dart';
import 'package:fusionreflow/ui/reader/widgets/reader_page_turner.dart';
import 'package:go_router/go_router.dart';

/// The reading screen of book [bookId]: page, header, footer; the system bars
/// are hidden while it is open.
class ReaderScreen extends ConsumerStatefulWidget {
  const new({required this.bookId, super.key});

  final String bookId;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  Size? _requestedSize;
  FlowStyle? _requestedStyle;

  @override
  void initState() {
    super.initState();
    unawaited(
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky),
    );
  }

  @override
  void dispose() {
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    super.dispose();
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.library);
    }
  }

  /// Tells the view model the size of the page text, once per change.
  void _reportViewport(Size size, FlowStyle style) {
    if (size == _requestedSize && style == _requestedStyle) return;
    _requestedSize = size;
    _requestedStyle = style;
    final model = readerViewModelProvider(widget.bookId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(ref.read(model.notifier).setViewport(size, style));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = Theme.of(context).brightness == Brightness.dark
        ? ReaderPalette.dark
        : ReaderPalette.light;
    final provider = readerViewModelProvider(widget.bookId);
    final media = MediaQuery.of(context);
    final cutout = media.displayFeatures
        // Only a cutout on the top edge covers the header; a side one (the
        // phone turned) does not.
        .where((f) => f.type == DisplayFeatureType.cutout && f.bounds.top <= 0)
        .fold<double>(0, (m, f) => math.max(m, f.bounds.bottom));
    final topInset = math.max(
      math.max(media.padding.top, media.viewPadding.top),
      cutout,
    );
    ref.listen(provider.select((s) => s.value?.saveFailures ?? 0), (
      before,
      after,
    ) {
      if (after > (before ?? 0)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.readerSavePositionFailed)));
      }
    });
    return Scaffold(
      backgroundColor: palette.pageBackground,
      body: ref
          .watch(provider)
          .when(
            loading: () => ReaderLoadingView(palette: palette),
            error: (error, _) => ReaderMessageView(
              message: error is BookNotFoundException
                  ? l10n.readerBookNotFound
                  : l10n.readerOpenFailed,
              palette: palette,
              onBack: _back,
            ),
            data: (state) => _page(context, state, palette, topInset),
          ),
    );
  }

  Widget _page(
    BuildContext context,
    ReaderState state,
    ReaderPalette palette,
    double topInset,
  ) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final metrics = ReaderPageMetrics.of(constraints.maxWidth);
        final style = metrics.style(palette);
        _reportViewport(
          Size(
            constraints.maxWidth,
            (constraints.maxHeight -
                    readerHeaderHeightFor(topInset) -
                    readerFooterHeight)
                .clamp(1, double.infinity),
          ),
          style,
        );
        final page = state.currentPage;
        if (page == null) return ReaderLoadingView(palette: palette);
        final title = state.chapterTitle;
        return Column(
          children: [
            ReaderHeader(
              title: title,
              color: palette.onSurfaceVariant,
              topInset: topInset,
            ),
            Expanded(
              child: ReaderPageTurner(
                current: page,
                previous: state.previousPage,
                next: state.nextPage,
                style: style,
                onTurn: (delta) => unawaited(
                  ref
                      .read(readerViewModelProvider(widget.bookId).notifier)
                      .showPage(delta),
                ),
              ),
            ),
            ReaderFooter(
              chapter: title == null
                  ? null
                  : l10n.readerChapterOf(
                      state.chapterIndex + 1,
                      state.chapterCount,
                    ),
              page: l10n.readerPageOf(
                state.pageInChapter,
                state.pagesInChapter,
              ),
              percent: l10n.readerPercent(state.percent),
              color: palette.onSurfaceVariant,
            ),
          ],
        );
      },
    );
  }
}
