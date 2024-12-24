import 'package:flutter/material.dart';

/// 数字键盘组件
class NumberPad extends StatelessWidget {
  /// 键盘按键点击回调
  final void Function(String) onKeyPressed;

  /// 删除按钮点击回调
  final VoidCallback onDelete;

  /// 确认按钮点击回调
  final VoidCallback onConfirm;

  /// 是否显示小数点
  final bool showDecimalPoint;

  /// 是否显示确认按钮
  final bool showConfirm;

  /// 构造函数
  const NumberPad({
    Key? key,
    required this.onKeyPressed,
    required this.onDelete,
    required this.onConfirm,
    this.showDecimalPoint = true,
    this.showConfirm = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(['1', '2', '3']),
          const SizedBox(height: 16.0),
          _buildRow(['4', '5', '6']),
          const SizedBox(height: 16.0),
          _buildRow(['7', '8', '9']),
          const SizedBox(height: 16.0),
          _buildRow([
            showDecimalPoint ? '.' : '',
            '0',
            'delete',
          ]),
          if (showConfirm) ...[
            const SizedBox(height: 16.0),
            _buildConfirmButton(),
          ],
        ],
      ),
    );
  }

  /// 构建按键行
  Widget _buildRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) => _buildKey(key)).toList(),
    );
  }

  /// 构建按键
  Widget _buildKey(String key) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: AspectRatio(
          aspectRatio: 1.5,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (key == 'delete') {
                  onDelete();
                } else {
                  onKeyPressed(key);
                }
              },
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                  child: key == 'delete'
                      ? const Icon(Icons.backspace_outlined)
                      : Text(
                          key,
                          style: const TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建确认按钮
  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 56.0,
      child: ElevatedButton(
        onPressed: onConfirm,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: const Text(
          '确认',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
} 