import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/consumption_trend_service.dart';
import '../services/transaction_service.dart';
import '../models/transaction.dart';

class ConsumptionTrendScreen extends StatefulWidget {
  const ConsumptionTrendScreen({Key? key}) : super(key: key);

  @override
  _ConsumptionTrendScreenState createState() => _ConsumptionTrendScreenState();
}

class _ConsumptionTrendScreenState extends State<ConsumptionTrendScreen> {
  final TransactionService _transactionService = TransactionService();
  ConsumptionTrend? _trend;
  bool _isLoading = true;
  String _selectedTimeRange = '近三月';
  final List<String> _timeRanges = ['本月', '近三月', '近半年', '近一年'];
  String _selectedTrendType = '日趋势';
  final List<String> _trendTypes = ['日趋势', '周趋势', '月趋势', '年趋势', '分类趋势'];

  @override
  void initState() {
    super.initState();
    _loadTrend();
  }

  Future<void> _loadTrend() async {
    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      DateTime startDate;
      final endDate = now;

      // 根据选择的时间范围确定开始日期
      switch (_selectedTimeRange) {
        case '本月':
          startDate = DateTime(now.year, now.month, 1);
          break;
        case '近三月':
          startDate = DateTime(now.year, now.month - 2, 1);
          break;
        case '近半年':
          startDate = DateTime(now.year, now.month - 5, 1);
          break;
        case '近一年':
          startDate = DateTime(now.year - 1, now.month, 1);
          break;
        default:
          startDate = DateTime(now.year, now.month - 2, 1);
      }

      final transactions = await _transactionService.getAll();
      final trend = ConsumptionTrendService.generateTrend(
        transactions: transactions,
        startDate: startDate,
        endDate: endDate,
      );

      setState(() {
        _trend = trend;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载趋势数据失败: ${e.toString()}')),
      );
      setState(() => _isLoading = false);
    }
  }

  Widget _buildTrendChart() {
    if (_trend == null) {
      return const Center(child: Text('暂无趋势数据'));
    }

    Map<String, double> data;
    switch (_selectedTrendType) {
      case '日趋势':
        data = _trend!.dailyTrends;
        break;
      case '周趋势':
        data = _trend!.weeklyTrends;
        break;
      case '月趋势':
        data = _trend!.monthlyTrends;
        break;
      case '年趋势':
        data = _trend!.yearlyTrends;
        break;
      case '分类趋势':
        data = _trend!.categoryTrends;
        break;
      default:
        data = _trend!.dailyTrends;
    }

    if (data.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    if (_selectedTrendType == '分类趋势') {
      return _buildPieChart(data);
    } else {
      return _buildLineChart(data);
    }
  }

  Widget _buildLineChart(Map<String, double> data) {
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final spots = sortedEntries.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < sortedEntries.length) {
                    final label = sortedEntries[value.toInt()].key;
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        _selectedTrendType == '日趋势' ? label.split('-')[2] :
                        _selectedTrendType == '周趋势' ? 'W${label.split('-W')[1]}' :
                        _selectedTrendType == '月趋势' ? label.split('-')[1] :
                        label,
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(spots: spots),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(Map<String, double> data) {
    final total = data.values.fold<double>(0, (sum, value) => sum + value);
    final sections = data.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      final color = Colors.primaries[entry.key.hashCode % Colors.primaries.length];
      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        color: color,
        radius: 100,
      );
    }).toList();

    return SizedBox(
      height: 300,
      child: PieChart(
        PieChartData(sections: sections),
      ),
    );
  }

  Widget _buildComparisonSection() {
    if (_trend == null) {
      return const SizedBox();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('同环比分析', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (_trend!.yearOverYear.isNotEmpty) ...[
              const Text('同比分析（年）'),
              ..._trend!.yearOverYear.entries.map((entry) {
                final growth = entry.value;
                final color = growth > 0 ? Colors.red : Colors.green;
                return ListTile(
                  title: Text(entry.key),
                  trailing: Text(
                    '${growth > 0 ? '+' : ''}${growth.toStringAsFixed(1)}%',
                    style: TextStyle(color: color),
                  ),
                );
              }),
            ],
            if (_trend!.monthOverMonth.isNotEmpty) ...[
              const Divider(),
              const Text('环比分析（月）'),
              ..._trend!.monthOverMonth.entries.map((entry) {
                final growth = entry.value;
                final color = growth > 0 ? Colors.red : Colors.green;
                return ListTile(
                  title: Text(entry.key),
                  trailing: Text(
                    '${growth > 0 ? '+' : ''}${growth.toStringAsFixed(1)}%',
                    style: TextStyle(color: color),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsSection() {
    if (_trend == null || _trend!.insights.isEmpty) {
      return const SizedBox();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('消费洞察', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ..._trend!.insights.map((insight) => ListTile(
              leading: const Icon(Icons.lightbulb_outline),
              title: Text(insight),
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('消费趋势'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedTimeRange,
            onSelected: (value) {
              setState(() {
                _selectedTimeRange = value;
                _loadTrend();
              });
            },
            itemBuilder: (context) => _timeRanges.map((range) {
              return PopupMenuItem<String>(
                value: range,
                child: Text(range),
              );
            }).toList(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTrend,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '分析周期: $_selectedTimeRange',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        DropdownButton<String>(
                          value: _selectedTrendType,
                          items: _trendTypes.map((type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedTrendType = value);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildTrendChart(),
                    const SizedBox(height: 24),
                    _buildComparisonSection(),
                    const SizedBox(height: 24),
                    _buildInsightsSection(),
                  ],
                ),
              ),
            ),
    );
  }
} 