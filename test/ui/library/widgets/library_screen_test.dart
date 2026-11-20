import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusionreflow/ui/spikes/widgets/hyphen_spike_screen.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('debug button opens hyphen spike', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const Key('open_hyphen_spike')));
    await tester.pumpAndSettle();

    expect(find.byType(HyphenSpikeScreen), findsOneWidget);
  });
}
