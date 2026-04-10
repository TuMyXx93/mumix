import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/debouncer.dart';
import '../providers/sales_price_provider.dart';

class SalesPriceCalculatorScreen extends StatefulWidget {
  const SalesPriceCalculatorScreen({super.key});

  @override
  State<SalesPriceCalculatorScreen> createState() =>
      _SalesPriceCalculatorScreenState();
}

class _SalesPriceCalculatorScreenState
    extends State<SalesPriceCalculatorScreen> {
  final _inputDebouncer = Debouncer(delay: const Duration(milliseconds: 350));
  final _currencyFormat = NumberFormat.currency(symbol: r'$', decimalDigits: 2);
  final _costController = TextEditingController();
  final _profitController = TextEditingController();
  final _taxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _costController.addListener(_onInputChanged);
    _profitController.addListener(_onInputChanged);
    _taxController.addListener(_onInputChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SalesPriceProvider>();
      if (provider.costInput.isNotEmpty) {
        _costController.text = provider.costInput;
        _profitController.text = provider.profitPercentInput;
        _taxController.text = provider.taxInput;
      }
    });
  }

  void _onInputChanged() {
    _inputDebouncer.run(_calculateSalePrice);
  }

  void _calculateSalePrice() {
    context.read<SalesPriceProvider>().calculatePrice(
          costStr: _costController.text,
          profitPercentStr: _profitController.text,
          taxStr: _taxController.text,
        );
  }

  String _formatCurrency(double value) {
    return _currencyFormat.format(value);
  }

  @override
  void dispose() {
    _costController.removeListener(_onInputChanged);
    _profitController.removeListener(_onInputChanged);
    _taxController.removeListener(_onInputChanged);
    _inputDebouncer.dispose();
    _costController.dispose();
    _profitController.dispose();
    _taxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Precio de Venta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _costController.clear();
              _profitController.clear();
              _taxController.clear();
              context.read<SalesPriceProvider>().clear();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tipo de Margen Toggle
            Consumer<SalesPriceProvider>(builder: (context, provider, child) {
              return Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      const Text('Sobre Costo', textAlign: TextAlign.center),
                      Switch(
                        value: provider.marginType == MarginType.margin,
                        onChanged: (value) {
                          provider.setMarginType(
                            value ? MarginType.margin : MarginType.markup,
                          );
                          if (_costController.text.isNotEmpty &&
                              _profitController.text.isNotEmpty) {
                            _onInputChanged();
                          }
                        },
                      ),
                      const Text('Sobre Venta (Pro)',
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _costController,
                      decoration: InputDecoration(
                        labelText: 'Costo Base del Producto',
                        prefixIcon: const Icon(Icons.inventory),
                        suffixIcon: _buildClearFieldButton(_costController),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el costo';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Costo inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _profitController,
                      decoration: InputDecoration(
                        labelText: 'Porcentaje de Ganancia (%)',
                        prefixIcon: const Icon(Icons.trending_up),
                        suffixIcon: _buildClearFieldButton(_profitController),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el porcentaje';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Porcentaje inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _taxController,
                      decoration: InputDecoration(
                        labelText: 'Impuestos / IVA (%) (Opcional)',
                        prefixIcon: const Icon(Icons.account_balance),
                        suffixIcon: _buildClearFieldButton(_taxController),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Consumer<SalesPriceProvider>(
              builder: (context, provider, child) {
                return AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  child: Column(
                    children: [
                      if (provider.errorMessage != null)
                        Card(
                          color: Theme.of(context).colorScheme.errorContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              provider.errorMessage!,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      if (provider.finalPrice != null)
                        Card(
                          elevation: 4,
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Resumen Financiero',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                const Divider(),
                                _buildResultRow('Precio sin impuestos:',
                                    provider.baseSalePrice!),
                                _buildResultRow(
                                    'Ganancia Neta:', provider.profitAmount!),
                                if (provider.taxAmount! > 0)
                                  _buildResultRow(
                                      'Impuestos:', provider.taxAmount!),
                                const Divider(),
                                Text(
                                  'Precio Final (Venta): ${_formatCurrency(provider.finalPrice!)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              _formatCurrency(value),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClearFieldButton(TextEditingController controller) {
    return IconButton(
      tooltip: 'Limpiar campo',
      icon: const Icon(Icons.close_rounded, size: 18),
      onPressed: () {
        controller.clear();
        _onInputChanged();
      },
    );
  }
}
