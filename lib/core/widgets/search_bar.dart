import 'package:flutter/material.dart';

/// 搜索建议项构建器
typedef SuggestionBuilder<T> = Widget Function(BuildContext context, T suggestion);

/// 搜索组件
class SearchBar<T> extends StatefulWidget {
  /// 搜索回调
  final ValueChanged<String>? onSearch;
  
  /// 文本变化回调
  final ValueChanged<String>? onChanged;
  
  /// 清除回调
  final VoidCallback? onClear;
  
  /// 建议列表
  final List<T>? suggestions;
  
  /// 建议项构建器
  final SuggestionBuilder<T>? suggestionBuilder;
  
  /// 建议项选择回调
  final ValueChanged<T>? onSuggestionSelected;
  
  /// 占位文本
  final String? hintText;
  
  /// 输入框装饰
  final InputDecoration? decoration;
  
  /// 是否显示清除按钮
  final bool showClearButton;
  
  /// 是否显示搜索按钮
  final bool showSearchButton;
  
  /// 是否自动获取焦点
  final bool autofocus;
  
  /// 是否只读
  final bool readOnly;
  
  /// 是否启用
  final bool enabled;
  
  /// 最大建议显示数量
  final int maxSuggestions;
  
  /// 防抖时间
  final Duration debounceDuration;

  const SearchBar({
    super.key,
    this.onSearch,
    this.onChanged,
    this.onClear,
    this.suggestions,
    this.suggestionBuilder,
    this.onSuggestionSelected,
    this.hintText,
    this.decoration,
    this.showClearButton = true,
    this.showSearchButton = true,
    this.autofocus = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxSuggestions = 5,
    this.debounceDuration = const Duration(milliseconds: 300),
  });

  @override
  State<SearchBar<T>> createState() => _SearchBarState<T>();
}

class _SearchBarState<T> extends State<SearchBar<T>> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _showSuggestions = false;
  String _lastSearchText = '';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _debounceTimer?.cancel();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null || widget.suggestions == null) return;

    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: context.size?.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 8),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: 56.0 * widget.maxSuggestions,
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: widget.suggestions!.length,
                itemBuilder: (context, index) {
                  final suggestion = widget.suggestions![index];
                  return InkWell(
                    onTap: () {
                      widget.onSuggestionSelected?.call(suggestion);
                      _removeOverlay();
                      _focusNode.unfocus();
                    },
                    child: widget.suggestionBuilder?.call(context, suggestion) ??
                        ListTile(
                          title: Text(suggestion.toString()),
                        ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
    setState(() => _showSuggestions = true);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _showSuggestions = false);
  }

  void _onSearchTextChanged(String value) {
    widget.onChanged?.call(value);
    
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      if (value != _lastSearchText) {
        _lastSearchText = value;
        widget.onSearch?.call(value);
      }
    });

    if (value.isEmpty) {
      widget.onClear?.call();
      _removeOverlay();
    } else if (widget.suggestions != null) {
      _showOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: (widget.decoration ?? const InputDecoration()).copyWith(
          hintText: widget.hintText ?? '搜索',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showClearButton && _controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    widget.onClear?.call();
                    _removeOverlay();
                  },
                ),
              if (widget.showSearchButton)
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    widget.onSearch?.call(_controller.text);
                    _focusNode.unfocus();
                  },
                ),
            ],
          ),
        ),
        onChanged: _onSearchTextChanged,
        autofocus: widget.autofocus,
        readOnly: widget.readOnly,
        enabled: widget.enabled,
      ),
    );
  }
} 