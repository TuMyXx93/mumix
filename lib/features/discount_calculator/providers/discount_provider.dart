import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DiscountType {
  percentage,
  fixedAmount,
}

class DiscountCalculatorProvider extends ChangeNotifier {
  final SharedPreferences _prefs;

  double? _subtotal;
  double? _finalPrice;
  double? _savedAmount;
  double? _taxAmount;
  String? _errorMessage;

  DiscountType _discountType = DiscountType.percentage;

  // Persisted Inputs
  String _originalPriceInput = '';
  String _primaryDiscountInput = '';
  String _additionalDiscountInput = '';
  String _taxInput = '';

  // Parsed Original Price for UI
  double? _originalPrice;

  DiscountCalculatorProvider(this._prefs) {
    _loadFromPrefs();
  }

  // Getters
  double? get subtotal => _subtotal;
  double? get finalPrice => _finalPrice;
  double? get savedAmount => _savedAmount;
  double? get taxAmount => _taxAmount;
  String? get errorMessage => _errorMessage;
  DiscountType get discountType => _discountType;

  String get originalPriceInput => _originalPriceInput;
  String get primaryDiscountInput => _primaryDiscountInput;
  String get additionalDiscountInput => _additionalDiscountInput;
  String get taxInput => _taxInput;
  double? get originalPrice => _originalPrice;

  void _loadFromPrefs() {
    _originalPriceInput = _prefs.getString('disc_orig') ?? '';
    _primaryDiscountInput = _prefs.getString('disc_pri') ?? '';
    _additionalDiscountInput = _prefs.getString('disc_add') ?? '';
    _taxInput = _prefs.getString('disc_tax') ?? '';
    final typeIndex = _prefs.getInt('disc_type') ?? 0;
    _discountType =
        typeIndex == 0 ? DiscountType.percentage : DiscountType.fixedAmount;

    if (_originalPriceInput.isNotEmpty && _primaryDiscountInput.isNotEmpty) {
      _calculateInternal();
    }
  }

  void setDiscountType(DiscountType type) {
    _discountType = type;
    _prefs.setInt('disc_type', type == DiscountType.percentage ? 0 : 1);
    notifyListeners();
  }

  void calculateDiscount({
    required String originalPriceStr,
    required String primaryDiscountStr,
    String additionalDiscountStr = '',
    String taxStr = '',
  }) {
    _originalPriceInput = originalPriceStr;
    _primaryDiscountInput = primaryDiscountStr;
    _additionalDiscountInput = additionalDiscountStr;
    _taxInput = taxStr;

    _prefs.setString('disc_orig', originalPriceStr);
    _prefs.setString('disc_pri', primaryDiscountStr);
    _prefs.setString('disc_add', additionalDiscountStr);
    _prefs.setString('disc_tax', taxStr);

    _calculateInternal();
  }

  void _calculateInternal() {
    _errorMessage = null;

    if (_originalPriceInput.trim().isEmpty ||
        _primaryDiscountInput.trim().isEmpty) {
      _clearResults();
      notifyListeners();
      return;
    }

    final origPrice = double.tryParse(_originalPriceInput);
    final primaryDiscount = double.tryParse(_primaryDiscountInput);
    final additionalDiscount = _additionalDiscountInput.isEmpty
        ? 0.0
        : double.tryParse(_additionalDiscountInput);
    final taxPercent = _taxInput.isEmpty ? 0.0 : double.tryParse(_taxInput);

    if (origPrice == null ||
        primaryDiscount == null ||
        additionalDiscount == null ||
        taxPercent == null) {
      _errorMessage = "Valores numéricos inválidos";
      _clearResults();
      notifyListeners();
      return;
    }

    if (origPrice < 0 ||
        primaryDiscount < 0 ||
        additionalDiscount < 0 ||
        taxPercent < 0) {
      _errorMessage = "Los valores no pueden ser negativos";
      _clearResults();
      notifyListeners();
      return;
    }

    _originalPrice = origPrice;
    double currentPrice = origPrice;
    double totalSaved = 0.0;

    if (_discountType == DiscountType.percentage) {
      if (primaryDiscount > 100 || additionalDiscount > 100) {
        _errorMessage = "Los porcentajes de descuento no pueden exceder 100%";
        _clearResults();
        notifyListeners();
        return;
      }

      double saved1 = currentPrice * (primaryDiscount / 100);
      currentPrice -= saved1;
      totalSaved += saved1;

      if (additionalDiscount > 0) {
        double saved2 = currentPrice * (additionalDiscount / 100);
        currentPrice -= saved2;
        totalSaved += saved2;
      }
    } else {
      double totalFixedDiscount = primaryDiscount + additionalDiscount;
      if (totalFixedDiscount > origPrice) {
        _errorMessage = "El descuento no puede ser mayor al precio original";
        _clearResults();
        notifyListeners();
        return;
      }
      totalSaved = totalFixedDiscount;
      currentPrice = origPrice - totalFixedDiscount;
    }

    _savedAmount = totalSaved;
    _subtotal = currentPrice;

    _taxAmount = _subtotal! * (taxPercent / 100);
    _finalPrice = _subtotal! + _taxAmount!;

    notifyListeners();
  }

  void _clearResults() {
    _originalPrice = null;
    _subtotal = null;
    _finalPrice = null;
    _savedAmount = null;
    _taxAmount = null;
  }

  void clear() {
    _originalPriceInput = '';
    _primaryDiscountInput = '';
    _additionalDiscountInput = '';
    _taxInput = '';

    _prefs.remove('disc_orig');
    _prefs.remove('disc_pri');
    _prefs.remove('disc_add');
    _prefs.remove('disc_tax');

    _clearResults();
    _errorMessage = null;
    notifyListeners();
  }
}
