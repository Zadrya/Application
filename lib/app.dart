// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:material_ui/material_ui.dart';

/// The root widget of the app.
///
/// A placeholder until the design foundation, localization and navigation
/// slices land: it only shows the app name.
class ZadryaApp extends StatelessWidget {
  /// Creates the root widget.
  const ZadryaApp({super.key});

  /// The text shown by the placeholder screen, used by tests to find it.
  static const placeholderText = 'Zadrya';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: placeholderText,
      home: Scaffold(
        body: Center(child: Text(placeholderText)),
      ),
    );
  }
}
