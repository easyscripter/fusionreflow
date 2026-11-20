import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fusionreflow/config/app_startup.dart';
import 'package:fusionreflow/ui/startup/widgets/startup_error_screen.dart';

/// Держит первый кадр (и нативный сплеш), пока приложение не готово; затем
/// показывает [child] или экран ошибки.
class StartupGate extends ConsumerStatefulWidget {
  /// Creates the gate. [onFirstFrame] replaces releasing the deferred first
  /// frame (tests).
  const new({required this.child, this.onFirstFrame, super.key});

  /// Приложение.
  final Widget child;

  /// Вызывается один раз, когда запуск завершился (успехом или ошибкой).
  final VoidCallback? onFirstFrame;

  @override
  ConsumerState<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends ConsumerState<StartupGate> {
  bool _frameAllowed = false;

  /// Один раз за жизнь State. Не синхронно в `build` и не через
  /// `addPostFrameCallback`: пока кадр отложен, тот не сработает.
  void _allowFirstFrame() {
    if (_frameAllowed) return;
    _frameAllowed = true;
    scheduleMicrotask(widget.onFirstFrame ?? _releaseDeferredFrame);
  }

  static void _releaseDeferredFrame() {
    final binding = WidgetsBinding.instance;
    // Без отложенного кадра (интеграционные тесты) allowFirstFrame упал бы.
    if (!binding.sendFramesToEngine) binding.allowFirstFrame();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(appStartupProvider, (_, next) {
      if (next case AsyncError(:final error, :final stackTrace)) {
        debugPrint('Startup failed: $error\n$stackTrace');
      }
    });
    return ref
        .watch(appStartupProvider)
        .when(
          data: (_) {
            _allowFirstFrame();
            return widget.child;
          },
          error: (_, _) {
            _allowFirstFrame();
            return StartupErrorScreen(
              onRetry: () => ref.invalidate(appStartupProvider),
            );
          },
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
        );
  }
}
