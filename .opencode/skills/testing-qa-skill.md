# Testing and QA Skill

This skill defines the standards for unit, widget, and integration testing within the Numix project.

## Core Principles
1. **Test-Driven Intent:** All new features or refactored logic must include corresponding tests. Do not wait for QA to flag missing coverage.
2. **Mocking Boundaries:** Avoid mocking the framework (Flutter/Dart core) itself. Focus on mocking external dependencies like HTTP clients, `shared_preferences` storage, or database layers using `mockito`.
3. **Isolated Tests:** Each test should be completely isolated and not rely on the state of previous tests. Use `setUp` and `tearDown` correctly.

## Unit Testing
- **Location:** `test/features/<feature_name>/...`
- **Scope:** Providers, business logic, calculations (e.g., `math-precision-skill.md` rules), models, and pure Dart logic.
- **Naming:** Test files must end in `_test.dart`. Test descriptions must clearly state the expected behavior (e.g., `test('calculates final price correctly with tax', () {...})`).

## Widget Testing
- **Scope:** UI components, screen layouts, and interaction flows (like buttons triggers, debouncers, or navigations).
- **Rule of Thumb:** Every feature's primary Screen must have at least one widget test validating its initial render and core interaction.
- **Pump Expectations:** Always `await tester.pumpAndSettle()` after an interaction (e.g., `tester.enterText`) to allow animations and debounce timers (like the 350ms calculation timer) to finish.
- **Theme injection:** Wrap widgets under test in `MaterialApp` and `ChangeNotifierProvider` (or similar dependency containers) to mirror the production app tree.

## Commands
- Run all tests: `flutter test`
- Run specific tests: `flutter test test/features/discount_calculator/screens/discount_calculator_screen_test.dart`
- Check coverage (requires `lcov`): `flutter test --coverage`
