import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/services/statistics_service.dart';

/// 分类统计页面
class CategoryStatsScreen extends StatefulWidget {
  /// 构造函数
  const CategoryStatsScreen({Key? key}) : super(key: key);

  @override
  State<CategoryStatsScreen> createState() => _CategoryStatsScreenState();
}

class _CategoryStatsScreenState extends State<CategoryStatsScreen> {
  final StatisticsService _statisticsService = StatisticsService();

  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _statistics;
  String _period = 'month';
  String _type = 'expense'; // 'income' or 'expense'
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

      final statistics = await _statisticsService.getCategoryStats(
        startDate: _startDate,
        endDate: _endDate,
        period: _period,
        type: _type,
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
        title: const Text('分类统计'),
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
                  value: 'expense',
                  label: Text('支出'),
                ),
                ButtonSegment<String>(
                  value: 'income',
                  label: Text('收入'),
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
          _buildPieChart(),
          const SizedBox(height: 16.0),
          _buildCategoryList(),
        ],
      ),
    );
  }

  /// 构建饼图
  Widget _buildPieChart() {
    final data = _statistics!['categories'] as List<Map<String, dynamic>>;
    final total = data.fold<double>(
      0,
      (sum, item) => sum + (item['amount'] as double),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '分类占比',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              height: 200.0,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: data.map((item) {
                    final amount = item['amount'] as double;
                    final percentage = amount / total;
                    return PieChartSectionData(
                      color: Color(item['color'] as int),
                      value: amount,
                      title: '${(percentage * 100).toStringAsFixed(1)}%',
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Wrap(
              spacing: 16.0,
              runSpacing: 8.0,
              children: data.map((item) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12.0,
                      height: 12.0,
                      decoration: BoxDecoration(
                        color: Color(item['color'] as int),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    Text(item['name'] as String),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建分类列表
  Widget _buildCategoryList() {
    final data = _statistics!['categories'] as List<Map<String, dynamic>>;
    final total = data.fold<double>(
      0,
      (sum, item) => sum + (item['amount'] as double),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '分类明细',
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
                final amount = item['amount'] as double;
                final percentage = amount / total;
                return ListTile(
                  leading: Container(
                    width: 32.0,
                    height: 32.0,
                    decoration: BoxDecoration(
                      color: Color(item['color'] as int),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      IconData(
                        item['icon'] as int,
                        fontFamily: 'MaterialIcons',
                      ),
                      color: Colors.white,
                      size: 20.0,
                    ),
                  ),
                  title: Text(item['name'] as String),
                  subtitle: Text(
                    '${(percentage * 100).toStringAsFixed(1)}%',
                  ),
                  trailing: Text(
                    amount.toStringAsFixed(2),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
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