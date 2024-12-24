import 'package:flutter/material.dart';
import '../models/tag_statistics.dart';
import '../services/tag_statistics_service.dart';

class TagStatisticsView extends StatefulWidget {
  final String tagId;
  final TagStatisticsService statisticsService;

  const TagStatisticsView({
    Key? key,
    required this.tagId,
    required this.statisticsService,
  }) : super(key: key);

  @override
  State<TagStatisticsView> createState() => _TagStatisticsViewState();
}

class _TagStatisticsViewState extends State<TagStatisticsView> {
  late Future<TagStatistics> _statisticsFuture;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  void _loadStatistics() {
    _statisticsFuture = widget.statisticsService.getTagStatistics(widget.tagId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TagStatistics>(
      future: _statisticsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('加载失败: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('暂无数据'));
        }

        final statistics = snapshot.data!;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicStatistics(statistics),
              const Divider(),
              _buildDistributionChart(statistics),
              const Divider(),
              _buildMonthlyUsageChart(statistics),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBasicStatistics(TagStatistics statistics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              statistics.tagName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('使用次数: ${statistics.usageCount}'),
            Text('总金额: ¥${statistics.totalAmount.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionChart(TagStatistics statistics) {
    // TODO: 实现分布统计图表
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('类型分布'),
      ),
    );
  }

  Widget _buildMonthlyUsageChart(TagStatistics statistics) {
    // TODO: 实现月度使用统计图表
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('月度使用统计'),
      ),
    );
  }
} 