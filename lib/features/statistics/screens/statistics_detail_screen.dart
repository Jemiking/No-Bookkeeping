import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsDetailScreen extends StatefulWidget {
  const StatisticsDetailScreen({super.key});

  @override
  State<StatisticsDetailScreen> createState() => _StatisticsDetailScreenState();
}

class _StatisticsDetailScreenState extends State<StatisticsDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedPeriod = 0; // 0: 本月, 1: 三个月, 2: 六个月, 3: 一年
  final List<String> _periods = ['本月', '三个月', '六个月', '一年'];

  // 模拟数据 - 收支明细数据
  final List<TransactionData> _transactions = [
    TransactionData('餐饮', '午餐', -30.0, DateTime(2024, 3, 15)),
    TransactionData('交通', '地铁', -5.0, DateTime(2024, 3, 15)),
    TransactionData('工资', '3月工资', 8000.0, DateTime(2024, 3, 15)),
    TransactionData('购物', '日用品', -200.0, DateTime(2024, 3, 14)),
    TransactionData('娱乐', '电影票', -80.0, DateTime(2024, 3, 14)),
  ];

  // 模拟数据 - 分类统计数据
  final List<CategoryData> _categories = [
    CategoryData('餐饮', 1580.0, 52),
    CategoryData('交通', 500.0, 45),
    CategoryData('购物', 1500.0, 20),
    CategoryData('娱乐', 800.0, 15),
    CategoryData('其他', 200.0, 8),
  ];

  // 模拟数据 - 每日趋势数据
  final List<DailyData> _dailyData = [
    DailyData(DateTime(2024, 3, 1), 200.0, 150.0),
    DailyData(DateTime(2024, 3, 2), 180.0, 120.0),
    DailyData(DateTime(2024, 3, 3), 220.0, 180.0),
    DailyData(DateTime(2024, 3, 4), 160.0, 140.0),
    DailyData(DateTime(2024, 3, 5), 240.0, 200.0),
    DailyData(DateTime(2024, 3, 6), 190.0, 160.0),
    DailyData(DateTime(2024, 3, 7), 210.0, 170.0),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('统计详情'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '收支明细'),
            Tab(text: '分类统计'),
            Tab(text: '趋势分析'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildPeriodSelector(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionList(),
                _buildCategoryStatistics(),
                _buildTrendAnalysis(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _periods.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedPeriod == index;
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ChoiceChip(
              label: Text(_periods[index]),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedPeriod = index);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final transaction = _transactions[index];
        final isIncome = transaction.amount > 0;
        
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isIncome ? Colors.green[100] : Colors.red[100],
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: isIncome ? Colors.green : Colors.red,
              ),
            ),
            title: Text(transaction.category),
            subtitle: Text(
              '${transaction.description} · ${_formatDate(transaction.date)}',
            ),
            trailing: Text(
              '${isIncome ? '+' : ''}¥${transaction.amount.abs().toStringAsFixed(2)}',
              style: TextStyle(
                color: isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryStatistics() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '分类排行',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ..._categories.map((category) => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(category.name),
                        ),
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LinearProgressIndicator(
                                value: category.count / 100,
                                backgroundColor: Colors.grey[200],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${category.count}笔 · ¥${category.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                )).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendAnalysis() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '每日趋势',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
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
                              if (value.toInt() >= 0 && 
                                  value.toInt() < _dailyData.length) {
                                return Text(
                                  '${_dailyData[value.toInt()].date.day}日',
                                  style: const TextStyle(fontSize: 12),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        // 收入曲线
                        LineChartBarData(
                          spots: _dailyData.asMap().entries.map((entry) {
                            return FlSpot(
                              entry.key.toDouble(),
                              entry.value.income,
                            );
                          }).toList(),
                          isCurved: true,
                          color: Colors.green,
                          dotData: FlDotData(show: false),
                        ),
                        // 支出曲线
                        LineChartBarData(
                          spots: _dailyData.asMap().entries.map((entry) {
                            return FlSpot(
                              entry.key.toDouble(),
                              entry.value.expense,
                            );
                          }).toList(),
                          isCurved: true,
                          color: Colors.red,
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildChartLegend('收入', Colors.green),
                    const SizedBox(width: 24),
                    _buildChartLegend('支出', Colors.red),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}月${date.day}日';
  }
}

class TransactionData {
  final String category;
  final String description;
  final double amount;
  final DateTime date;

  TransactionData(this.category, this.description, this.amount, this.date);
}

class CategoryData {
  final String name;
  final double amount;
  final int count;

  CategoryData(this.name, this.amount, this.count);
}

class DailyData {
  final DateTime date;
  final double income;
  final double expense;

  DailyData(this.date, this.income, this.expense);
} 