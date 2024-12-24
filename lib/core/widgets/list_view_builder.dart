import 'package:flutter/material.dart';

/// 列表项构建器
typedef ItemBuilder<T> = Widget Function(BuildContext context, T item, int index);

/// 列表分组构建器
typedef GroupBuilder<T> = Widget Function(BuildContext context, String group, List<T> items);

/// 列表头部构建器
typedef HeaderBuilder = Widget Function(BuildContext context);

/// 列表底部构建器
typedef FooterBuilder = Widget Function(BuildContext context);

/// 列表空状态构建器
typedef EmptyBuilder = Widget Function(BuildContext context);

/// 列表加载状态构建器
typedef LoadingBuilder = Widget Function(BuildContext context);

/// 列表错误状态构建器
typedef ErrorBuilder = Widget Function(BuildContext context, dynamic error);

/// 列表组件
class ListViewBuilder<T> extends StatelessWidget {
  /// 数据列表
  final List<T> items;
  
  /// 列表项构建器
  final ItemBuilder<T> itemBuilder;
  
  /// 分组键获取器
  final String Function(T item)? groupBy;
  
  /// 分组构建器
  final GroupBuilder<T>? groupBuilder;
  
  /// 头部构建器
  final HeaderBuilder? headerBuilder;
  
  /// 底部��建器
  final FooterBuilder? footerBuilder;
  
  /// 空状态构建器
  final EmptyBuilder? emptyBuilder;
  
  /// 加载状态构建器
  final LoadingBuilder? loadingBuilder;
  
  /// 错误状态构建器
  final ErrorBuilder? errorBuilder;
  
  /// 是否正在加载
  final bool isLoading;
  
  /// 错误信息
  final dynamic error;
  
  /// 是否显示分隔线
  final bool showDivider;
  
  /// 分隔线构建器
  final IndexedWidgetBuilder? dividerBuilder;
  
  /// 内边距
  final EdgeInsetsGeometry? padding;
  
  /// 是否可滚动
  final bool scrollable;
  
  /// 滚动控制器
  final ScrollController? controller;
  
  /// 滚动物理特性
  final ScrollPhysics? physics;
  
  /// 是否反向
  final bool reverse;
  
  /// 是否缓存
  final bool shrinkWrap;
  
  /// 主轴方向
  final Axis scrollDirection;

  const ListViewBuilder({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.groupBy,
    this.groupBuilder,
    this.headerBuilder,
    this.footerBuilder,
    this.emptyBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.isLoading = false,
    this.error,
    this.showDivider = true,
    this.dividerBuilder,
    this.padding,
    this.scrollable = true,
    this.controller,
    this.physics,
    this.reverse = false,
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    // 处理加载状态
    if (isLoading) {
      return loadingBuilder?.call(context) ??
          const Center(child: CircularProgressIndicator());
    }

    // 处理错误状态
    if (error != null) {
      return errorBuilder?.call(context, error) ??
          Center(child: Text('错误: $error'));
    }

    // 处理空状态
    if (items.isEmpty) {
      return emptyBuilder?.call(context) ??
          const Center(child: Text('暂无数据'));
    }

    // 构建列表内容
    Widget content;
    if (groupBy != null) {
      content = _buildGroupedList(context);
    } else {
      content = _buildSimpleList(context);
    }

    // 添加头部和底部
    if (headerBuilder != null || footerBuilder != null) {
      content = Column(
        children: [
          if (headerBuilder != null) headerBuilder!(context),
          Expanded(child: content),
          if (footerBuilder != null) footerBuilder!(context),
        ],
      );
    }

    return content;
  }

  /// 构建分组列表
  Widget _buildGroupedList(BuildContext context) {
    // 按分组键对数据进行分组
    final groups = <String, List<T>>{};
    for (var item in items) {
      final key = groupBy!(item);
      if (!groups.containsKey(key)) {
        groups[key] = [];
      }
      groups[key]!.add(item);
    }

    // 构建分组列表
    final children = <Widget>[];
    groups.forEach((group, groupItems) {
      if (groupBuilder != null) {
        children.add(groupBuilder!(context, group, groupItems));
      } else {
        children.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  group,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...groupItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    itemBuilder(context, item, index),
                    if (showDivider && index < groupItems.length - 1)
                      dividerBuilder?.call(context, index) ??
                          const Divider(height: 1),
                  ],
                );
              }).toList(),
            ],
          ),
        );
      }
    });

    return _wrapScrollView(context, children);
  }

  /// 构建简单列表
  Widget _buildSimpleList(BuildContext context) {
    final children = items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return Column(
        children: [
          itemBuilder(context, item, index),
          if (showDivider && index < items.length - 1)
            dividerBuilder?.call(context, index) ??
                const Divider(height: 1),
        ],
      );
    }).toList();

    return _wrapScrollView(context, children);
  }

  /// 包装滚动视图
  Widget _wrapScrollView(BuildContext context, List<Widget> children) {
    final content = Column(children: children);
    
    if (!scrollable) {
      return Padding(
        padding: padding ?? EdgeInsets.zero,
        child: content,
      );
    }

    return SingleChildScrollView(
      controller: controller,
      physics: physics,
      reverse: reverse,
      padding: padding,
      scrollDirection: scrollDirection,
      child: content,
    );
  }
} 