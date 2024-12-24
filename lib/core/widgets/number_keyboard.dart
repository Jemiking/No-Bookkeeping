import 'package:flutter/material.dart';

/// 数字键盘按键类型
enum KeyType {
  number,
  decimal,
  delete,
  done,
}

/// 数字键盘按键数据
class KeyData {
  final String label;
  final KeyType type;
  final VoidCallback? onTap;

  const KeyData({
    required this.label,
    required this.type,
    this.onTap,
  });
}

/// 数字键盘组件
class NumberKeyboard extends StatelessWidget {
  /// 数字输入回调
  final ValueChanged<String>? onNumberInput;
  
  /// 删除回调
  final VoidCallback? onDelete;
  
  /// 小数点输入回调
  final VoidCallback? onDecimalPoint;
  
  /// 完成回调
  final VoidCallback? onDone;
  
  /// 是否显示完成按钮
  final bool showDoneButton;
  
  /// 是否允许小数点
  final bool allowDecimal;
  
  /// 按键高度
  final double keyHeight;
  
  /// 按键间距
  final double keySpacing;
  
  /// 背景色
  final Color? backgroundColor;
  
  /// 按键颜色
  final Color? keyColor;
  
  /// 文字颜色
  final Color? textColor;

  const NumberKeyboard({
    super.key,
    this.onNumberInput,
    this.onDelete,
    this.onDecimalPoint,
    this.onDone,
    this.showDoneButton = true,
    this.allowDecimal = true,
    this.keyHeight = 60,
    this.keySpacing = 1,
    this.backgroundColor,
    this.keyColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // 使用主题色或默认颜色
    final bgColor = backgroundColor ?? theme.scaffoldBackgroundColor;
    final kColor = keyColor ?? theme.colorScheme.surface;
    final tColor = textColor ?? theme.colorScheme.onSurface;

    return Container(
      color: bgColor,
      child: Column(
        children: [
          _buildKeyRow(['1', '2', '3'], kColor, tColor),
          SizedBox(height: keySpacing),
          _buildKeyRow(['4', '5', '6'], kColor, tColor),
          SizedBox(height: keySpacing),
          _buildKeyRow(['7', '8', '9'], kColor, tColor),
          SizedBox(height: keySpacing),
          _buildBottomRow(kColor, tColor),
        ],
      ),
    );
  }

  /// 构建按键行
  Widget _buildKeyRow(List<String> keys, Color keyColor, Color textColor) {
    return Row(
      children: keys.map((key) {
        return Expanded(
          child: _buildKey(
            KeyData(
              label: key,
              type: KeyType.number,
              onTap: () => onNumberInput?.call(key),
            ),
            keyColor,
            textColor,
          ),
        );
      }).toList(),
    );
  }

  /// 构建底部行
  Widget _buildBottomRow(Color keyColor, Color textColor) {
    return Row(
      children: [
        Expanded(
          child: _buildKey(
            KeyData(
              label: allowDecimal ? '.' : '00',
              type: allowDecimal ? KeyType.decimal : KeyType.number,
              onTap: allowDecimal 
                ? () => onDecimalPoint?.call()
                : () => onNumberInput?.call('00'),
            ),
            keyColor,
            textColor,
          ),
        ),
        Expanded(
          child: _buildKey(
            KeyData(
              label: '0',
              type: KeyType.number,
              onTap: () => onNumberInput?.call('0'),
            ),
            keyColor,
            textColor,
          ),
        ),
        Expanded(
          child: showDoneButton
              ? _buildKey(
                  KeyData(
                    label: '完成',
                    type: KeyType.done,
                    onTap: onDone,
                  ),
                  keyColor,
                  textColor,
                )
              : _buildKey(
                  KeyData(
                    label: '←',
                    type: KeyType.delete,
                    onTap: onDelete,
                  ),
                  keyColor,
                  textColor,
                ),
        ),
      ],
    );
  }

  /// 构建单个按键
  Widget _buildKey(KeyData data, Color keyColor, Color textColor) {
    return Material(
      color: keyColor,
      child: InkWell(
        onTap: data.onTap,
        child: Container(
          height: keyHeight,
          alignment: Alignment.center,
          child: Text(
            data.label,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
} 