import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/discount_provider.dart';

class DiscountCalculatorScreen extends StatefulWidget {
  const DiscountCalculatorScreen({super.key});

  @override
  State<DiscountCalculatorScreen> createState() =>
      _DiscountCalculatorScreenState();
}

class _DiscountCalculatorScreenState extends State<DiscountCalculatorScreen> {
  final _currencyFormat = NumberFormat.currency(symbol: r'$', decimalDigits: 2);
  final _formKey = GlobalKey<FormState>();
  final _originalPriceController = TextEditingController();
  final _primaryDiscountController = TextEditingController();
  final _additionalDiscountController = TextEditingController();
  final _taxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Restaurar los valores guardados en el Provider al volver a entrar a la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DiscountCalculatorProvider>();
      if (provider.originalPriceInput.isNotEmpty) {
        _originalPriceController.text = provider.originalPriceInput;
        _primaryDiscountController.text = provider.primaryDiscountInput;
        _additionalDiscountController.text = provider.additionalDiscountInput;
        _taxController.text = provider.taxInput;
      }
    });
  }

  void _calculateDiscount() {
    if (_formKey.currentState!.validate()) {
      context.read<DiscountCalculatorProvider>().calculateDiscount(
            originalPriceStr: _originalPriceController.text,
            primaryDiscountStr: _primaryDiscountController.text,
            additionalDiscountStr: _additionalDiscountController.text,
            taxStr: _taxController.text,
          );
    }
  }

  String _formatCurrency(double value) {
    return _currencyFormat.format(value);
  }

  @override
  void dispose() {
    _originalPriceController.dispose();
    _primaryDiscountController.dispose();
    _additionalDiscountController.dispose();
    _taxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de Descuentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _originalPriceController.clear();
              _primaryDiscountController.clear();
              _additionalDiscountController.clear();
              _taxController.clear();
              context.read<DiscountCalculatorProvider>().clear();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tipo de Descuento Toggle
              Consumer<DiscountCalculatorProvider>(
                  builder: (context, provider, child) {
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
                        const Text('Porcentaje (%)',
                            textAlign: TextAlign.center),
                        Switch(
                          value:
                              provider.discountType == DiscountType.fixedAmount,
                          onChanged: (value) {
                            provider.setDiscountType(
                              value
                                  ? DiscountType.fixedAmount
                                  : DiscountType.percentage,
                            );
                            if (_originalPriceController.text.isNotEmpty &&
                                _primaryDiscountController.text.isNotEmpty) {
                              _calculateDiscount();
                            }
                          },
                        ),
                        const Text('Monto Fijo (\$)',
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
                        controller: _originalPriceController,
                        decoration: InputDecoration(
                          labelText: 'Precio Original',
                          prefixIcon: const Icon(Icons.attach_money),
                          suffixIcon: _buildClearFieldButton(
                            _originalPriceController,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese el precio';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Por favor ingrese un número válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Consumer<DiscountCalculatorProvider>(
                          builder: (context, provider, child) {
                        bool isPercentage =
                            provider.discountType == DiscountType.percentage;
                        return TextFormField(
                          controller: _primaryDiscountController,
                          decoration: InputDecoration(
                            labelText: isPercentage
                                ? 'Descuento Principal (%)'
                                : 'Descuento Principal (\$)',
                            prefixIcon: Icon(
                                isPercentage ? Icons.percent : Icons.money_off),
                            suffixIcon: _buildClearFieldButton(
                              _primaryDiscountController,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}')),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese el descuento';
                            }
                            final discount = double.tryParse(value);
                            if (discount == null) {
                              return 'Por favor ingrese un número válido';
                            }
                            if (isPercentage &&
                                (discount < 0 || discount > 100)) {
                              return 'El porcentaje debe estar entre 0 y 100';
                            }
                            return null;
                          },
                        );
                      }),
                      const SizedBox(height: 16),
                      Consumer<DiscountCalculatorProvider>(
                          builder: (context, provider, child) {
                        bool isPercentage =
                            provider.discountType == DiscountType.percentage;
                        return TextFormField(
                          controller: _additionalDiscountController,
                          decoration: InputDecoration(
                            labelText: isPercentage
                                ? 'Descuento Adicional Sucesivo (%)'
                                : 'Descuento Adicional (\$)',
                            prefixIcon: Icon(
                                isPercentage ? Icons.percent : Icons.money_off),
                            suffixIcon: _buildClearFieldButton(
                              _additionalDiscountController,
                            ),
                            hintText: 'Opcional',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}')),
                          ],
                        );
                      }),
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
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _calculateDiscount,
                icon: const Icon(Icons.calculate),
                label: const Text('Calcular Descuento'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 24),
              Consumer<DiscountCalculatorProvider>(
                builder: (context, provider, child) {
                  if (provider.errorMessage != null) {
                    return Card(
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
                    );
                  }

                  if (provider.finalPrice != null &&
                      provider.savedAmount != null) {
                    return Card(
                      elevation: 4,
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Resumen del Descuento',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const Divider(),
                            _buildResultRow('Precio Original:',
                                provider.originalPrice ?? 0.0),
                            _buildResultRow(
                                'Total Ahorrado:', provider.savedAmount!,
                                color: Theme.of(context).colorScheme.primary),
                            if (provider.taxAmount! > 0) ...[
                              _buildResultRow('Subtotal:', provider.subtotal!),
                              _buildResultRow('Impuestos:', provider.taxAmount!,
                                  color: Theme.of(context).colorScheme.error),
                            ],
                            const Divider(),
                            Text(
                              'Precio Final a Pagar: ${_formatCurrency(provider.finalPrice!)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, double value, {Color? color}) {
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
              (color == Theme.of(context).colorScheme.primary ? '-' : '') +
                  _formatCurrency(value),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600, color: color),
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
        setState(() {});
      },
    );
  }
}
