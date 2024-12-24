import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'number_pad.dart';

/// 金额输入组件
class AmountInput extends StatefulWidget {
  /// 初始金额
  final double? initialAmount;

  /// 金额改变回调
  final ValueChanged<double> onAmountChanged;

  /// 货币符号
  final String currencySymbol;

  /// 小数位数
  final int decimalPlaces;

  /// 最大金额
  final double? maxAmount;

  /// 构造函数
  const AmountInput({
    Key? key,
    this.initialAmount,
    required this.onAmountChanged,
    this.currencySymbol = '¥',
    this.decimalPlaces = 2,
    this.maxAmount,
  }) : super(key: key);

  @override
  State<AmountInput> createState() => _AmountInputState();
}

class _AmountInputState extends State<AmountInput> {
  late String _amountStr;
  bool _hasDecimalPoint = false;

  @override
  void initState() {
    super.initState();
    _amountStr = widget.initialAmount?.toString() ?? '0';
    _hasDecimalPoint = _amountStr.contains('.');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAmountDisplay(),
        const SizedBox(height: 16.0),
        NumberPad(
          onKeyPressed: _handleKeyPressed,
          onDelete: _handleDelete,
          onConfirm: _handleConfirm,
          showDecimalPoint: !_hasDecimalPoint &&
              _amountStr.length < 10 &&
              widget.decimalPlaces > 0,
        ),
      ],
    );
  }

  /// 构建金额显示
  Widget _buildAmountDisplay() {
    final amount = double.tryParse(_amountStr) ?? 0.0;
    final formattedAmount = NumberFormat.currency(
      symbol: widget.currencySymbol,
      decimalDigits: widget.decimalPlaces,
    ).format(amount);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 16.0,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        formattedAmount,
        style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// ���理按键点击
  void _handleKeyPressed(String key) {
    if (key == '.') {
      if (_hasDecimalPoint || widget.decimalPlaces == 0) {
        return;
      }
      setState(() {
        _amountStr = _amountStr == '0' ? '0.' : '$_amountStr.';
        _hasDecimalPoint = true;
      });
      return;
    }

    if (_amountStr == '0' && key != '.') {
      setState(() {
        _amountStr = key;
      });
      return;
    }

    if (_hasDecimalPoint) {
      final decimalPart = _amountStr.split('.')[1];
      if (decimalPart.length >= widget.decimalPlaces) {
        return;
      }
    }

    if (_amountStr.length >= 10) {
      return;
    }

    final newAmount = double.tryParse('$_amountStr$key');
    if (newAmount != null &&
        (widget.maxAmount == null || newAmount <= widget.maxAmount!)) {
      setState(() {
        _amountStr = '$_amountStr$key';
      });
    }
  }

  /// 处理删除
  void _handleDelete() {
    if (_amountStr.isEmpty || _amountStr == '0') {
      return;
    }

    setState(() {
      if (_amountStr.endsWith('.')) {
        _hasDecimalPoint = false;
      }
      _amountStr = _amountStr.substring(0, _amountStr.length - 1);
      if (_amountStr.isEmpty) {
        _amountStr = '0';
      }
    });
  }

  /// 处理确认
  void _handleConfirm() {
    final amount = double.tryParse(_amountStr);
    if (amount != null) {
      widget.onAmountChanged(amount);
    }
  }
} 