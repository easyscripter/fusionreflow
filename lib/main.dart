import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fusionreflow/fusion_reflow_app.dart';

void main() {
  // Первый кадр (и нативный сплеш) ждёт StartupGate: он разрешит кадр, когда
  // мост Rust и хранилище готовы.
  WidgetsFlutterBinding.ensureInitialized().deferFirstFrame();
  runApp(const ProviderScope(child: FusionReflowApp()));
}
