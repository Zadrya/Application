// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:zadrya/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the app starts and shows the placeholder screen', (
    tester,
  ) async {
    await tester.pumpWidget(const ZadryaApp());
    await tester.pumpAndSettle();

    expect(find.text(ZadryaApp.placeholderText), findsOneWidget);
  });
}
