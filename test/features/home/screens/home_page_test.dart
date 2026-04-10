import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numix/core/providers/theme_provider.dart';
import 'package:numix/features/discount_calculator/providers/discount_provider.dart';
import 'package:numix/features/discount_calculator/screens/discount_calculator_screen.dart';
import 'package:numix/features/home/screens/home_page.dart';
import 'package:numix/features/sales_price_calculator/providers/sales_price_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpHome(
    WidgetTester tester,
    SharedPreferences prefs, {
    Size? logicalSize,
    double textScaleFactor = 1.0,
  }) async {
    if (logicalSize != null) {
      tester.view.physicalSize = logicalSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
          ChangeNotifierProvider(
              create: (_) => DiscountCalculatorProvider(prefs)),
          ChangeNotifierProvider(create: (_) => SalesPriceProvider(prefs)),
        ],
        child: MaterialApp(
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: TextScaler.linear(textScaleFactor),
              ),
              child: child!,
            );
          },
          home: const MyHomePage(title: 'Calculadora Numix'),
        ),
      ),
    );
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('home shows dashboard title and main tools', (tester) async {
    final prefs = await SharedPreferences.getInstance();

    await pumpHome(tester, prefs);

    expect(find.text('Panel principal'), findsOneWidget);
    expect(find.text('Calculadora de Descuentos'), findsOneWidget);
    expect(find.text('Calculadora de Precios'), findsOneWidget);
    expect(find.text('Inventario de Productos'), findsOneWidget);
    expect(find.text('Historial de Ventas'), findsOneWidget);
  });

  testWidgets('home navigates to discount calculator screen', (tester) async {
    final prefs = await SharedPreferences.getInstance();

    await pumpHome(tester, prefs);

    await tester.tap(find.text('Calculadora de Descuentos'));
    await tester.pumpAndSettle();

    expect(find.byType(DiscountCalculatorScreen), findsOneWidget);
  });

  testWidgets('home keeps compact dashboard card height baseline', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await pumpHome(tester, prefs);

    expect(find.byType(Card), findsNWidgets(4));
    final firstCardSize = tester.getSize(find.byType(Card).first);
    expect(firstCardSize.height, closeTo(124, 0.1));
  });

  testWidgets(
      'home scales card height for tablet and large text without overflow', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await pumpHome(
      tester,
      prefs,
      logicalSize: const Size(1280, 800),
      textScaleFactor: 1.4,
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final firstCardSize = tester.getSize(find.byType(Card).first);
    expect(firstCardSize.height, greaterThan(124));
  });
}
