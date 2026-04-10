import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:numix/features/sales_price_calculator/providers/sales_price_provider.dart';

void main() {
  group('SalesPriceProvider', () {
    late SalesPriceProvider provider;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      provider = SalesPriceProvider(prefs);
    });

    test('Initial values are correct', () {
      expect(provider.baseSalePrice, isNull);
      expect(provider.finalPrice, isNull);
      expect(provider.profitAmount, isNull);
      expect(provider.taxAmount, isNull);
      expect(provider.errorMessage, isNull);
      expect(provider.marginType, MarginType.markup);
    });

    test('Calculates Markup correctly without tax', () {
      // Cost: 100, Profit: 20%
      provider.calculatePrice(costStr: '100', profitPercentStr: '20');

      expect(provider.errorMessage, isNull);
      expect(provider.profitAmount, 20.0);
      expect(provider.baseSalePrice, 120.0);
      expect(provider.taxAmount, 0.0);
      expect(provider.finalPrice, 120.0);
    });

    test('Calculates Markup correctly with tax', () {
      // Cost: 100, Profit: 20%, Tax: 10%
      provider.calculatePrice(
          costStr: '100', profitPercentStr: '20', taxStr: '10');

      expect(provider.errorMessage, isNull);
      expect(provider.profitAmount, 20.0);
      expect(provider.baseSalePrice, 120.0);
      expect(provider.taxAmount, 12.0);
      expect(provider.finalPrice, 132.0);
    });

    test('Calculates Gross Margin correctly without tax', () {
      provider.setMarginType(MarginType.margin);
      // Cost: 80, Margin: 20% -> Price should be 100 (since 20% of 100 is 20, Cost is 80)
      provider.calculatePrice(costStr: '80', profitPercentStr: '20');

      expect(provider.errorMessage, isNull);
      expect(provider.profitAmount, 20.0);
      expect(provider.baseSalePrice, 100.0);
      expect(provider.taxAmount, 0.0);
      expect(provider.finalPrice, 100.0);
    });

    test('Gross Margin fails if percentage is >= 100', () {
      provider.setMarginType(MarginType.margin);
      provider.calculatePrice(costStr: '100', profitPercentStr: '100');

      expect(
          provider.errorMessage, 'El margen sobre venta debe ser menor a 100%');
      expect(provider.finalPrice, isNull);
    });

    test('Sets error for invalid strings', () {
      provider.calculatePrice(costStr: 'abc', profitPercentStr: '20');
      expect(provider.errorMessage, 'Valores numéricos inválidos');
    });

    test('Sets error for negative values', () {
      provider.calculatePrice(costStr: '100', profitPercentStr: '-10');
      expect(provider.errorMessage, 'Los valores no pueden ser negativos');
    });

    test('Empty required inputs clear results without error', () {
      provider.calculatePrice(costStr: '100', profitPercentStr: '20');
      expect(provider.finalPrice, 120.0);

      provider.calculatePrice(costStr: '', profitPercentStr: '20');

      expect(provider.errorMessage, isNull);
      expect(provider.finalPrice, isNull);
      expect(provider.baseSalePrice, isNull);
    });

    test('Clears correctly', () {
      provider.calculatePrice(costStr: '100', profitPercentStr: '20');
      provider.clear();
      expect(provider.finalPrice, isNull);
      expect(provider.errorMessage, isNull);
    });

    test('Persists and loads data from SharedPreferences', () async {
      provider.calculatePrice(costStr: '100', profitPercentStr: '20');

      final newProvider = SalesPriceProvider(prefs);

      expect(newProvider.costInput, '100');
      expect(newProvider.profitPercentInput, '20');
      expect(newProvider.finalPrice, 120.0);
    });
  });
}
