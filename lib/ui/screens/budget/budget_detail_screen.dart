import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/database/models/budget.dart';
import '../../../core/services/budget_service.dart';
import '../../../core/services/category_service.dart';

/// 预算详情页面
class BudgetDetailScreen extends StatefulWidget {
  /// 预算ID
  final int budgetId;

  /// 构造函数
  const BudgetDetailScreen({
    Key? key,
    required this.budgetId,
  }) : super(key: key);

  @override
  State<BudgetDetailScreen> createState() => _BudgetDetailScreenState();
}

class _BudgetDetailScreenState extends State<BudgetDetailScreen> {
  final BudgetService _budgetService = BudgetService();
  final CategoryService _categoryService = CategoryService();

  Budget? _budget;
  Map<String, dynamic>? _usage;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBudget();
  }

  /// 加载预算信息
  Future<void> _loadBudget() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final budget = await _budgetService.getBudget(widget.budgetId);
      if (budget == null) {
        setState(() {
          _error = '预算不存在';
          _isLoading = false;
        });
        return;
      }

      final usage = await _budgetService.getUsage(widget.budgetId);

      setState(() {
        _budget = budget;
        _usage = usage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '加载预算失败：$e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_budget?.name ?? '预算详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: 跳转到预算编辑页面
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'delete':
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('删除预算'),
                        content: const Text('确定要删除该预算吗？删除后无法恢复。'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: Text(
                              '删除',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirmed == true) {
                    try {
                      await _budgetService.deleteBudget(widget.budgetId);
                      if (mounted) {
                        Navigator.of(context).pop(true);
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('删除预算失败：$e'),
                          ),
                        );
                      }
                    }
                  }
                  break;
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    '删除',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  /// 构建页面主体
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _loadBudget,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBudget,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildOverviewCard(),
          const SizedBox(height: 16.0),
          _buildUsageChart(),
          const SizedBox(height: 16.0),
          _buildDetailsList(),
        ],
      ),
    );
  }

  /// 构建概览卡片
  Widget _buildOverviewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _budget!.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4.0),
                      FutureBuilder(
                        future: _categoryService.getCategory(_budget!.categoryId),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox();
                          }
                          final category = snapshot.data!;
                          return Text(
                            category.name,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _budget!.isEnabled,
                  onChanged: (value) async {
                    try {
                      final budget = _budget!.copyWith(isEnabled: value);
                      await _budgetService.updateBudget(budget);
                      setState(() {
                        _budget = budget;
                      });
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('更新预算状态失败：$e'),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            LinearProgressIndicator(
              value: _budget!.amount / _budget!.limit,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                _budget!.amount >= _budget!.limit
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '已使用',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      _budget!.amount.toStringAsFixed(2),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _budget!.amount >= _budget!.limit
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '预算限额',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      _budget!.limit.toStringAsFixed(2),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            if (_budget!.note != null) ...[
              const SizedBox(height: 16.0),
              Text(
                _budget!.note!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建使用情况图表
  Widget _buildUsageChart() {
    if (_usage == null || _usage!['daily'] == null) {
      return const SizedBox();
    }

    final dailyData = _usage!['daily'] as List<Map<String, dynamic>>;
    final spots = <FlSpot>[];

    for (var i = 0; i < dailyData.length; i++) {
      final item = dailyData[i];
      spots.add(FlSpot(i.toDouble(), item['amount'] as double));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '使用趋势',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              height: 200.0,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= dailyData.length) {
                            return const SizedBox();
                          }
                          final item = dailyData[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              item['date'] as String,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建明细列表
  Widget _buildDetailsList() {
    if (_usage == null || _usage!['transactions'] == null) {
      return const SizedBox();
    }

    final transactions = _usage!['transactions'] as List<Map<String, dynamic>>;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '使用明细',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16.0),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              separatorBuilder: (context, index) {
                return const Divider();
              },
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return ListTile(
                  title: Text(transaction['note'] as String? ?? '无备注'),
                  subtitle: Text(
                    transaction['date'] as String,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                  trailing: Text(
                    (transaction['amount'] as double).toStringAsFixed(2),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  onTap: () {
                    // TODO: 跳转到交易详情页面
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 