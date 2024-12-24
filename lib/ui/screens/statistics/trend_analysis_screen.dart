import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/services/statistics_service.dart';

/// 趋势分析页面
class TrendAnalysisScreen extends StatefulWidget {
  /// 构造函数
  const TrendAnalysisScreen({Key? key}) : super(key: key);

  @override
  State<TrendAnalysisScreen> createState() => _TrendAnalysisScreenState();
}

class _TrendAnalysisScreenState extends State<TrendAnalysisScreen> {
  final StatisticsService _statisticsService = StatisticsService();

  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>>? _statistics;
  String _period = 'month';
  String _type = 'all'; // 'all', 'income', 'expense'
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  /// 加载统计数据
  Future<void> _loadStatistics() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final statistics = await _statisticsService.getTrendAnalysis(
        startDate: _startDate,
        endDate: _endDate,
        period: _period,
        type: _type == 'all' ? null : _type,
      );

      setState(() {
        _statistics = statistics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '加载统计数据失败：$e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('趋势分析'),
        actions: [
          // 时间范围选择
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _period = value;
                switch (value) {
                  case 'week':
                    _startDate = DateTime.now().subtract(const Duration(days: 7));
                    break;
                  case 'month':
                    _startDate = DateTime.now().subtract(const Duration(days: 30));
                    break;
                  case 'year':
                    _startDate = DateTime.now().subtract(const Duration(days: 365));
                    break;
                }
                _loadStatistics();
              });
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: 'week',
                  child: Text('最近一周'),
                ),
                const PopupMenuItem(
                  value: 'month',
                  child: Text('最近一月'),
                ),
                const PopupMenuItem(
                  value: 'year',
                  child: Text('最近一年'),
                ),
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    _period == 'week'
                        ? '最近一周'
                        : _period == 'month'
                            ? '最近一月'
                            : '最近一年',
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 收入/支出切换
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment<String>(
                  value: 'all',
                  label: Text('全部'),
                ),
                ButtonSegment<String>(
                  value: 'income',
                  label: Text('收入'),
                ),
                ButtonSegment<String>(
                  value: 'expense',
                  label: Text('支出'),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _type = newSelection.first;
                  _loadStatistics();
                });
              },
            ),
          ),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
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
              onPressed: _loadStatistics,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_statistics == null || _statistics!.isEmpty) {
      return const Center(
        child: Text('暂无数据'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStatistics,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildTrendChart(),
          const SizedBox(height: 16.0),
          _buildTrendList(),
        ],
      ),
    );
  }

  /// 构建趋势图表
  Widget _buildTrendChart() {
    final data = _statistics!;
    final spots = <FlSpot>[];

    for (var i = 0; i < data.length; i++) {
      final item = data[i];
      final amount = _type == 'all'
          ? (item['income'] as double) - (item['expense'] as double)
          : item[_type] as double;
      spots.add(FlSpot(i.toDouble(), amount));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '趋势图表',
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
                          if (value.toInt() >= data.length) {
                            return const SizedBox();
                          }
                          final item = data[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              item['label'] as String,
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
                      color: _type == 'expense'
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.primary,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: (_type == 'expense'
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.primary)
                            .withOpacity(0.1),
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

  /// 构建趋势列表
  Widget _buildTrendList() {
    final data = _statistics!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '趋势明细',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16.0),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.length,
              separatorBuilder: (context, index) {
                return const Divider();
              },
              itemBuilder: (context, index) {
                final item = data[index];
                final income = item['income'] as double;
                final expense = item['expense'] as double;
                final balance = income - expense;
                return ListTile(
                  title: Text(item['label'] as String),
                  subtitle: Text(
                    _type == 'all'
                        ? '收入：${income.toStringAsFixed(2)}  支出：${expense.toStringAsFixed(2)}'
                        : _type == 'income'
                            ? '收入：${income.toStringAsFixed(2)}'
                            : '支出：${expense.toStringAsFixed(2)}',
                  ),
                  trailing: Text(
                    _type == 'all'
                        ? balance.toStringAsFixed(2)
                        : _type == 'income'
                            ? income.toStringAsFixed(2)
                            : expense.toStringAsFixed(2),
                    style: TextStyle(
                      color: _type == 'expense'
                          ? Theme.of(context).colorScheme.error
                          : _type == 'income'
                              ? Theme.of(context).colorScheme.primary
                              : balance >= 0
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 