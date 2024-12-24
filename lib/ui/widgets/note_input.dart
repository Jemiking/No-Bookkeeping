import 'package:flutter/material.dart';

/// 备注输入组件
class NoteInput extends StatefulWidget {
  /// 初始备注
  final String? initialNote;

  /// 备注改变回调
  final ValueChanged<String> onNoteChanged;

  /// 最大长度
  final int? maxLength;

  /// 占位文本
  final String? placeholder;

  /// 是否自动获取焦点
  final bool autofocus;

  /// 构造函数
  const NoteInput({
    Key? key,
    this.initialNote,
    required this.onNoteChanged,
    this.maxLength,
    this.placeholder,
    this.autofocus = false,
  }) : super(key: key);

  @override
  State<NoteInput> createState() => _NoteInputState();
}

class _NoteInputState extends State<NoteInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote);
    _focusNode = FocusNode();

    _controller.addListener(() {
      widget.onNoteChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '备注',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (widget.maxLength != null) ...[
                const Spacer(),
                Text(
                  '${_controller.text.length}/${widget.maxLength}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _controller.text.length >= (widget.maxLength ?? 0)
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            maxLength: widget.maxLength,
            maxLines: null,
            autofocus: widget.autofocus,
            decoration: InputDecoration(
              hintText: widget.placeholder ?? '添加备注...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              contentPadding: const EdgeInsets.all(12.0),
              counterText: '',
            ),
            style: Theme.of(context).textTheme.bodyLarge,
            onChanged: (value) {
              setState(() {});
            },
          ),
          const SizedBox(height: 8.0),
          _buildQuickNotes(),
        ],
      ),
    );
  }

  /// 构建快速备注
  Widget _buildQuickNotes() {
    final quickNotes = [
      '早餐',
      '午餐',
      '晚餐',
      '交通',
      '购物',
      '娱乐',
    ];

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: quickNotes.map((note) {
        return ActionChip(
          label: Text(note),
          onPressed: () {
            final currentText = _controller.text;
            final newText = currentText.isEmpty
                ? note
                : '$currentText${currentText.endsWith(' ') ? '' : ' '}$note';
            if (widget.maxLength == null ||
                newText.length <= widget.maxLength!) {
              _controller.text = newText;
              _controller.selection = TextSelection.fromPosition(
                TextPosition(offset: newText.length),
              );
            }
          },
        );
      }).toList(),
    );
  }
} 