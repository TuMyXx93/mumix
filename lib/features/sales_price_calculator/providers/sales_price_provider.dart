import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MarginType {
  markup,
  margin,
}

class SalesPriceProvider extends ChangeNotifier {
  final SharedPreferences _prefs;

  double? _baseSalePrice;
  double? _finalPrice;
  double? _profitAmount;
  double? _taxAmount;
  String? _errorMessage;

  MarginType _marginType = MarginType.markup;

  // Persisted Inputs
  String _costInput = '';
  String _profitPercentInput = '';
  String _taxInput = '';

  SalesPriceProvider(this._prefs) {
    _loadFromPrefs();
  }

  // Getters
  double? get baseSalePrice => _baseSalePrice;
  double? get finalPrice => _finalPrice;
  double? get profitAmount => _profitAmount;
  double? get taxAmount => _taxAmount;
  String? get errorMessage => _errorMessage;
  MarginType get marginType => _marginType;

  String get costInput => _costInput;
  String get profitPercentInput => _profitPercentInput;
  String get taxInput => _taxInput;

  void _loadFromPrefs() {
    _costInput = _prefs.getString('sales_cost') ?? '';
    _profitPercentInput = _prefs.getString('sales_profit') ?? '';
    _taxInput = _prefs.getString('sales_tax') ?? '';

    final typeIndex = _prefs.getInt('sales_margin_type') ?? 0;
    _marginType = typeIndex == 0 ? MarginType.markup : MarginType.margin;

    if (_costInput.isNotEmpty && _profitPercentInput.isNotEmpty) {
      _calculateInternal();
    }
  }

  void setMarginType(MarginType type) {
    _marginType = type;
    _prefs.setInt('sales_margin_type', type == MarginType.markup ? 0 : 1);
    notifyListeners();
  }

  void calculatePrice({
    required String costStr,
    required String profitPercentStr,
    String taxStr = '0',
  }) {
    _costInput = costStr;
    _profitPercentInput = profitPercentStr;
    _taxInput = taxStr;

    _prefs.setString('sales_cost', costStr);
    _prefs.setString('sales_profit', profitPercentStr);
    _prefs.setString('sales_tax', taxStr);

    _calculateInternal();
  }

  void _calculateInternal() {
    _errorMessage = null;

    if (_costInput.trim().isEmpty || _profitPercentInput.trim().isEmpty) {
      _clearResults();
      notifyListeners();
      return;
    }

    final cost = double.tryParse(_costInput);
    final profitPercent = double.tryParse(_profitPercentInput);
    final taxPercent = _taxInput.isEmpty ? 0.0 : double.tryParse(_taxInput);

    if (cost == null || profitPercent == null || taxPercent == null) {
      _errorMessage = "Valores numéricos inválidos";
      _clearResults();
      notifyListeners();
      return;
    }

    if (cost < 0 || profitPercent < 0 || taxPercent < 0) {
      _errorMessage = "Los valores no pueden ser negativos";
      _clearResults();
      notifyListeners();
      return;
    }

    if (_marginType == MarginType.margin && profitPercent >= 100) {
      _errorMessage = "El margen sobre venta debe ser menor a 100%";
      _clearResults();
      notifyListeners();
      return;
    }

    if (_marginType == MarginType.markup) {
      _profitAmount = cost * (profitPercent / 100);
      _baseSalePrice = cost + _profitAmount!;
    } else {
      _baseSalePrice = cost / (1 - (profitPercent / 100));
      _profitAmount = _baseSalePrice! - cost;
    }

    _taxAmount = _baseSalePrice! * (taxPercent / 100);
    _finalPrice = _baseSalePrice! + _taxAmount!;

    notifyListeners();
  }

  void _clearResults() {
    _baseSalePrice = null;
    _finalPrice = null;
    _profitAmount = null;
    _taxAmount = null;
  }

  void clear() {
    _costInput = '';
    _profitPercentInput = '';
    _taxInput = '';

    _prefs.remove('sales_cost');
    _prefs.remove('sales_profit');
    _prefs.remove('sales_tax');

    _clearResults();
    _errorMessage = null;
    notifyListeners();
  }
}
