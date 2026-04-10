import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numix/core/themes/app_theme.dart';

void main() {
  test('AppTheme exposes Material 3 light and dark themes', () {
    final light = AppTheme.lightTheme;
    final dark = AppTheme.darkTheme;

    expect(light.useMaterial3, isTrue);
    expect(dark.useMaterial3, isTrue);
    expect(light.brightness, Brightness.light);
    expect(dark.brightness, Brightness.dark);
  });

  test('AppTheme has shared input styling configured', () {
    final light = AppTheme.lightTheme;

    expect(light.inputDecorationTheme.filled, isTrue);
    expect(light.inputDecorationTheme.enabledBorder, isNotNull);
    expect(light.inputDecorationTheme.focusedBorder, isNotNull);
  });
}
