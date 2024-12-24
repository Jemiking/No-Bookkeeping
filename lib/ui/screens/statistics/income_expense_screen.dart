import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/services/statistics_service.dart';

/// 收支统计页面
class IncomeExpenseScreen extends StatefulWidget {
  /// 构造函数
  const IncomeExpenseScreen({Key? key}) : super(key: key);

  @override
  State<IncomeExpenseScreen> createState() => _IncomeExpenseScreenState();
}

class _IncomeExpenseScreenState extends State<IncomeExpenseScreen> {
  final StatisticsService _statisticsService = StatisticsService();

  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _statistics;
  String _period = 'month';
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

      final statistics = await _statisticsService.getIncomeExpenseStats(
        startDate: _startDate,
        endDate: _endDate,
        period: _period,
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
        title: const Text('收支统计'),
        actions: [
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
              onPressed: _loadStatistics,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_statistics == null) {
      return const Center(
        child: Text('暂无数据'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStatistics,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 16.0),
          _buildTrendChart(),
          const SizedBox(height: 16.0),
          _buildDetailsList(),
        ],
      ),
    );
  }

  /// 构建汇总卡片
  Widget _buildSummaryCard() {
    final income = _statistics!['summary']['income'] as double;
    final expense = _statistics!['summary']['expense'] as double;
    final balance = income - expense;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '收支汇总',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    label: '收入',
                    amount: income,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: _buildSummaryItem(
                    label: '支出',
                    amount: expense,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: _buildSummaryItem(
                    label: '结余',
                    amount: balance,
                    color: balance >= 0
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建汇总项
  Widget _buildSummaryItem({
    required String label,
    required double amount,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
        const SizedBox(height: 4.0),
        Text(
          amount.toStringAsFixed(2),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  /// 构建趋势图表
  Widget _buildTrendChart() {
    final data = _statistics!['trend'] as List<Map<String, dynamic>>;
    final incomeSpots = <FlSpot>[];
    final expenseSpots = <FlSpot>[];

    for (var i = 0; i < data.length; i++) {
      final item = data[i];
      incomeSpots.add(FlSpot(i.toDouble(), item['income'] as double));
      expenseSpots.add(FlSpot(i.toDouble(), item['expense'] as double));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '收支趋势',
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
                      spots: incomeSpots,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                      ),
                    ),
                    LineChartBarData(
                      spots: expenseSpots,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.error,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color:
                            Theme.of(context).colorScheme.error.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12.0,
                  height: 12.0,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4.0),
                const Text('收入'),
                const SizedBox(width: 16.0),
                Container(
                  width: 12.0,
                  height: 12.0,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4.0),
                const Text('支出'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建明细列表
  Widget _buildDetailsList() {
    final data = _statistics!['details'] as List<Map<String, dynamic>>;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '收支明细',
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
                return ListTile(
                  title: Text(item['date'] as String),
                  subtitle: Text(
                    '收入：${item['income'].toStringAsFixed(2)}  支出：${item['expense'].toStringAsFixed(2)}',
                  ),
                  trailing: Text(
                    (item['income'] - item['expense']).toStringAsFixed(2),
                    style: TextStyle(
                      color: item['income'] >= item['expense']
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