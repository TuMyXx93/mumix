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

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('home shows dashboard title and main tools', (tester) async {
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
          ChangeNotifierProvider(
              create: (_) => DiscountCalculatorProvider(prefs)),
          ChangeNotifierProvider(create: (_) => SalesPriceProvider(prefs)),
        ],
        child: const MaterialApp(
          home: MyHomePage(title: 'Calculadora Numix'),
        ),
      ),
    );

    expect(find.text('Panel principal'), findsOneWidget);
    expect(find.text('Calculadora de Descuentos'), findsOneWidget);
    expect(find.text('Calculadora de Precios'), findsOneWidget);
    expect(find.text('Inventario de Productos'), findsOneWidget);
    expect(find.text('Historial de Ventas'), findsOneWidget);
  });

  testWidgets('home navigates to discount calculator screen', (tester) async {
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
          ChangeNotifierProvider(
              create: (_) => DiscountCalculatorProvider(prefs)),
          ChangeNotifierProvider(create: (_) => SalesPriceProvider(prefs)),
        ],
        child: const MaterialApp(
          home: MyHomePage(title: 'Calculadora Numix'),
        ),
      ),
    );

    await tester.tap(find.text('Calculadora de Descuentos'));
    await tester.pumpAndSettle();

    expect(find.byType(DiscountCalculatorScreen), findsOneWidget);
  });
}
