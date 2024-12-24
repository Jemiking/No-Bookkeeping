import 'package:flutter/material.dart';
import '../domain/currency_converter.dart';

class CurrencyConverterDialog extends StatefulWidget {
  final CurrencyConverter currencyConverter;
  final String initialCurrency;
  final double initialAmount;

  const CurrencyConverterDialog({
    Key? key,
    required this.currencyConverter,
    required this.initialCurrency,
    required this.initialAmount,
  }) : super(key: key);

  @override
  State<CurrencyConverterDialog> createState() => _CurrencyConverterDialogState();
}

class _CurrencyConverterDialogState extends State<CurrencyConverterDialog> {
  late TextEditingController _amountController;
  String? _selectedTargetCurrency;
  List<String> _supportedCurrencies = [];
  double? _convertedAmount;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.initialAmount.toString(),
    );
    _loadSupportedCurrencies();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadSupportedCurrencies() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final currencies = await widget.currencyConverter.getSupportedCurrencies();
      setState(() {
        _supportedCurrencies = currencies;
        if (currencies.contains(widget.initialCurrency)) {
          _selectedTargetCurrency = currencies.firstWhere(
            (c) => c != widget.initialCurrency,
          );
        }
      });
    } catch (e) {
      setState(() {
        _error = '加载支持的货币失败: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _convertCurrency() async {
    if (_selectedTargetCurrency == null) {
      setState(() {
        _error = '请选择目标货币';
      });
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null) {
      setState(() {
        _error = '请输入有效的金额';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final converted = await widget.currencyConverter.convert(
        amount,
        widget.initialCurrency,
        _selectedTargetCurrency!,
      );
      setState(() {
        _convertedAmount = converted;
      });
    } catch (e) {
      setState(() {
        _error = '货币转换失败: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('货币转换'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: '金额 (${widget.initialCurrency})',
                errorText: _error,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
            else ...[
              DropdownButtonFormField<String>(
                value: _selectedTargetCurrency,
                decoration: const InputDecoration(
                  labelText: '目标货币',
                ),
                items: _supportedCurrencies
                    .where((c) => c != widget.initialCurrency)
                    .map((currency) {
                  return DropdownMenuItem(
                    value: currency,
                    child: Text(currency),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTargetCurrency = value;
                    _convertedAmount = null;
                  });
                },
              ),
              if (_convertedAmount != null) ...[
                const SizedBox(height: 16),
                Text(
                  '转换结果: ${_convertedAmount!.toStringAsFixed(2)} $_selectedTargetCurrency',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('关闭'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _convertCurrency,
          child: const Text('转换'),
        ),
      ],
    );
  }
} 