import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:numix/features/discount_calculator/providers/discount_provider.dart';

void main() {
  group('DiscountCalculatorProvider', () {
    late DiscountCalculatorProvider provider;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      provider = DiscountCalculatorProvider(prefs);
    });

    test('Initial values are null', () {
      expect(provider.finalPrice, isNull);
      expect(provider.savedAmount, isNull);
      expect(provider.subtotal, isNull);
      expect(provider.taxAmount, isNull);
      expect(provider.errorMessage, isNull);
      expect(provider.discountType, DiscountType.percentage);
    });

    test('Calculates simple percentage discount correctly', () {
      provider.calculateDiscount(
          originalPriceStr: '100', primaryDiscountStr: '20');

      expect(provider.errorMessage, isNull);
      expect(provider.savedAmount, 20.0);
      expect(provider.subtotal, 80.0);
      expect(provider.taxAmount, 0.0);
      expect(provider.finalPrice, 80.0);
    });

    test('Calculates sequential percentage discount correctly', () {
      provider.calculateDiscount(
        originalPriceStr: '100',
        primaryDiscountStr: '20',
        additionalDiscountStr: '10',
      );

      expect(provider.errorMessage, isNull);
      expect(provider.savedAmount, 28.0);
      expect(provider.subtotal, 72.0);
      expect(provider.finalPrice, 72.0);
    });

    test('Calculates fixed amount discount correctly', () {
      provider.setDiscountType(DiscountType.fixedAmount);
      provider.calculateDiscount(
        originalPriceStr: '150',
        primaryDiscountStr: '30',
        additionalDiscountStr: '15',
      );

      expect(provider.errorMessage, isNull);
      expect(provider.savedAmount, 45.0);
      expect(provider.subtotal, 105.0);
      expect(provider.finalPrice, 105.0);
    });

    test('Calculates correctly with tax', () {
      provider.calculateDiscount(
        originalPriceStr: '100',
        primaryDiscountStr: '20',
        taxStr: '15',
      );

      expect(provider.errorMessage, isNull);
      expect(provider.savedAmount, 20.0);
      expect(provider.subtotal, 80.0);
      expect(provider.taxAmount, 12.0);
      expect(provider.finalPrice, 92.0);
    });

    test('Fixed discount exceeds original price shows error', () {
      provider.setDiscountType(DiscountType.fixedAmount);
      provider.calculateDiscount(
          originalPriceStr: '100', primaryDiscountStr: '120');

      expect(provider.errorMessage,
          'El descuento no puede ser mayor al precio original');
      expect(provider.finalPrice, isNull);
    });

    test('Percentage > 100 shows error', () {
      provider.calculateDiscount(
          originalPriceStr: '100', primaryDiscountStr: '110');

      expect(provider.errorMessage,
          'Los porcentajes de descuento no pueden exceder 100%');
      expect(provider.finalPrice, isNull);
    });

    test('Negative values show error', () {
      provider.calculateDiscount(
          originalPriceStr: '-100', primaryDiscountStr: '20');

      expect(provider.errorMessage, 'Los valores no pueden ser negativos');
      expect(provider.finalPrice, isNull);
    });

    test('Empty required inputs clear results without error', () {
      provider.calculateDiscount(
          originalPriceStr: '100', primaryDiscountStr: '20');
      expect(provider.finalPrice, 80.0);

      provider.calculateDiscount(
          originalPriceStr: '', primaryDiscountStr: '20');

      expect(provider.errorMessage, isNull);
      expect(provider.finalPrice, isNull);
      expect(provider.savedAmount, isNull);
    });

    test('Clears values correctly', () {
      provider.calculateDiscount(
          originalPriceStr: '100', primaryDiscountStr: '20');
      provider.clear();

      expect(provider.finalPrice, isNull);
      expect(provider.savedAmount, isNull);
      expect(provider.errorMessage, isNull);
    });

    test('Persists and loads data from SharedPreferences', () async {
      provider.calculateDiscount(
          originalPriceStr: '200', primaryDiscountStr: '50');

      // Simulate app restart / new provider instance
      final newProvider = DiscountCalculatorProvider(prefs);

      expect(newProvider.originalPriceInput, '200');
      expect(newProvider.primaryDiscountInput, '50');
      expect(newProvider.finalPrice, 100.0);
    });
  });
}
