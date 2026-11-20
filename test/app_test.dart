// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:zadrya/app.dart';

void main() {
  testWidgets('shows the placeholder screen', (tester) async {
    await tester.pumpWidget(const ZadryaApp());

    expect(find.text(ZadryaApp.placeholderText), findsOneWidget);
  });
}
