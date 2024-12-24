import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 金额输入框组件
class AmountInput extends StatefulWidget {
  /// 初始金额
  final double? initialValue;
  
  /// 金额变化回调
  final ValueChanged<double>? onChanged;
  
  /// 币种
  final String? currency;
  
  /// 最大值
  final double? maxValue;
  
  /// 最小值
  final double? minValue;
  
  /// 小数位数
  final int decimalPlaces;
  
  /// 是否允许负数
  final bool allowNegative;
  
  /// 是否显示货币符号
  final bool showCurrencySymbol;
  
  /// 输入框装饰
  final InputDecoration? decoration;
  
  /// 是否自动获取焦点
  final bool autofocus;
  
  /// 是否只读
  final bool readOnly;

  const AmountInput({
    super.key,
    this.initialValue,
    this.onChanged,
    this.currency,
    this.maxValue,
    this.minValue,
    this.decimalPlaces = 2,
    this.allowNegative = false,
    this.showCurrencySymbol = true,
    this.decoration,
    this.autofocus = false,
    this.readOnly = false,
  });

  @override
  State<AmountInput> createState() => _AmountInputState();
}

class _AmountInputState extends State<AmountInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue?.toStringAsFixed(widget.decimalPlaces) ?? '',
    );
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.numberWithOptions(
        decimal: true,
        signed: widget.allowNegative,
      ),
      textAlign: TextAlign.end,
      autofocus: widget.autofocus,
      readOnly: widget.readOnly,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      decoration: (widget.decoration ?? const InputDecoration()).copyWith(
        prefixText: widget.showCurrencySymbol ? (widget.currency ?? '¥') : null,
        prefixStyle: theme.textTheme.titleLarge?.copyWith(
          color: theme.textTheme.bodyMedium?.color,
        ),
      ),
      inputFormatters: [
        // 允许负数
        if (widget.allowNegative)
          FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d{0,2}')),
        // 不允许负数
        if (!widget.allowNegative)
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        // 限制小数位数
        TextInputFormatter.withFunction((oldValue, newValue) {
          if (newValue.text.isEmpty) return newValue;
          try {
            final value = double.parse(newValue.text);
            if (widget.maxValue != null && value > widget.maxValue!) {
              return oldValue;
            }
            if (widget.minValue != null && value < widget.minValue!) {
              return oldValue;
            }
            return newValue;
          } catch (e) {
            return oldValue;
          }
        }),
      ],
      onChanged: (value) {
        if (value.isEmpty) {
          widget.onChanged?.call(0);
          return;
        }
        try {
          final amount = double.parse(value);
          widget.onChanged?.call(amount);
        } catch (e) {
          // 解析失败时不触发回调
        }
      },
    );
  }
} 