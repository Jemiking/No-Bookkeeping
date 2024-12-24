import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/consumption_habit_service.dart';
import '../services/transaction_service.dart';
import '../models/transaction.dart';

class ConsumptionHabitScreen extends StatefulWidget {
  const ConsumptionHabitScreen({Key? key}) : super(key: key);

  @override
  _ConsumptionHabitScreenState createState() => _ConsumptionHabitScreenState();
}

class _ConsumptionHabitScreenState extends State<ConsumptionHabitScreen> {
  final TransactionService _transactionService = TransactionService();
  ConsumptionHabit? _habit;
  bool _isLoading = true;
  String _selectedTimeRange = '近三月';
  final List<String> _timeRanges = ['本月', '近三月', '近半年', '近一年'];
  String _selectedDistribution = '星期分布';
  final List<String> _distributionTypes = ['星期分布', '时段分布', '地点分布', '商家分布'];

  @override
  void initState() {
    super.initState();
    _loadHabit();
  }

  Future<void> _loadHabit() async {
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
      final habit = ConsumptionHabitService.generateHabitAnalysis(
        transactions: transactions,
        startDate: startDate,
        endDate: endDate,
      );

      setState(() {
        _habit = habit;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载习惯数据失败: ${e.toString()}')),
      );
      setState(() => _isLoading = false);
    }
  }

  Widget _buildDistributionChart() {
    if (_habit == null) {
      return const Center(child: Text('暂无习惯数据'));
    }

    Map<String, double> data;
    switch (_selectedDistribution) {
      case '星期分布':
        data = _habit!.weekdayDistribution;
        break;
      case '时段分布':
        data = _habit!.hourlyDistribution;
        break;
      case '地点分布':
        data = _habit!.locationDistribution;
        break;
      case '商家分布':
        data = _habit!.merchantDistribution;
        break;
      default:
        data = _habit!.weekdayDistribution;
    }

    if (data.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    return Column(
      children: [
        Text(
          _selectedDistribution,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: data.values.reduce((a, b) => a > b ? a : b) * 1.2,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.blueGrey,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${data.entries.elementAt(groupIndex).key}\n¥${rod.toY.toStringAsFixed(2)}',
                      const TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < data.length) {
                        final label = data.keys.elementAt(value.toInt());
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            _selectedDistribution == '时段分布' ? label.split(':')[0] : 
                            label.length > 4 ? '${label.substring(0, 4)}...' : label,
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: data.entries.map((entry) {
                return BarChartGroupData(
                  x: data.keys.toList().indexOf(entry.key),
                  barRods: [
                    BarChartRodData(
                      toY: entry.value,
                      color: Colors.blue,
                      width: 16,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCorrelationSection() {
    if (_habit == null || _habit!.categoryCorrelation.isEmpty) {
      return const SizedBox();
    }

    final sortedCorrelations = _habit!.categoryCorrelation.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('分类相关性', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...sortedCorrelations.take(5).map((entry) {
              final categories = entry.key.split('-');
              return ListTile(
                title: Text('${categories[0]} → ${categories[1]}'),
                trailing: Text('${(entry.value * 100).toStringAsFixed(1)}%'),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequentCombinationsSection() {
    if (_habit == null || _habit!.frequentCombinations.isEmpty) {
      return const SizedBox();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('常见消费组合', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ..._habit!.frequentCombinations.entries.map((entry) {
              return ListTile(
                leading: const Icon(Icons.shopping_cart),
                title: Text(entry.value.join(' + ')),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsSection() {
    if (_habit == null || _habit!.insights.isEmpty) {
      return const SizedBox();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('消费习惯洞察', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ..._habit!.insights.map((insight) => ListTile(
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
        title: const Text('消费习惯'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedTimeRange,
            onSelected: (value) {
              setState(() {
                _selectedTimeRange = value;
                _loadHabit();
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
              onRefresh: _loadHabit,
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
                          value: _selectedDistribution,
                          items: _distributionTypes.map((type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedDistribution = value);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildDistributionChart(),
                    const SizedBox(height: 24),
                    _buildCorrelationSection(),
                    const SizedBox(height: 24),
                    _buildFrequentCombinationsSection(),
                    const SizedBox(height: 24),
                    _buildInsightsSection(),
                  ],
                ),
              ),
            ),
    );
  }
} 