import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// 图表类型
enum ChartType {
  line,
  bar,
  pie,
  scatter,
  radar,
}

/// 图表数据点
class ChartPoint {
  final dynamic x;
  final double y;
  final String? label;
  final Color? color;

  const ChartPoint({
    required this.x,
    required this.y,
    this.label,
    this.color,
  });
}

/// 图表数据系列
class ChartSeries {
  final String name;
  final List<ChartPoint> data;
  final Color? color;
  final bool? showLine;
  final bool? showPoints;
  final bool? showArea;
  final double? lineWidth;
  final List<Color>? gradientColors;

  const ChartSeries({
    required this.name,
    required this.data,
    this.color,
    this.showLine = true,
    this.showPoints = true,
    this.showArea = false,
    this.lineWidth = 2.0,
    this.gradientColors,
  });
}

/// 图表组件
class ChartView extends StatefulWidget {
  /// 图表类型
  final ChartType type;
  
  /// 数据系列列表
  final List<ChartSeries> series;
  
  /// 标题
  final String? title;
  
  /// X轴标题
  final String? xAxisTitle;
  
  /// Y轴标题
  final String? yAxisTitle;
  
  /// 是否显示图例
  final bool showLegend;
  
  /// 是否显示网格
  final bool showGrid;
  
  /// 是否显示工具提示
  final bool showTooltip;
  
  /// 是否允许缩放
  final bool enableZoom;
  
  /// 图表高度
  final double height;
  
  /// 图表内边距
  final EdgeInsets padding;
  
  /// 背景色
  final Color? backgroundColor;
  
  /// 网格颜色
  final Color? gridColor;
  
  /// 文本样式
  final TextStyle? textStyle;
  
  /// 自定义工具提示构建器
  final Widget Function(List<ChartPoint>)? tooltipBuilder;

  const ChartView({
    super.key,
    required this.type,
    required this.series,
    this.title,
    this.xAxisTitle,
    this.yAxisTitle,
    this.showLegend = true,
    this.showGrid = true,
    this.showTooltip = true,
    this.enableZoom = false,
    this.height = 300,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.gridColor,
    this.textStyle,
    this.tooltipBuilder,
  });

  @override
  State<ChartView> createState() => _ChartViewState();
}

class _ChartViewState extends State<ChartView> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: widget.height,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? theme.cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null) ...[
            Text(
              widget.title!,
              style: widget.textStyle?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ) ?? theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
          ],
          Expanded(
            child: _buildChart(theme),
          ),
          if (widget.showLegend) ...[
            const SizedBox(height: 16),
            _buildLegend(theme),
          ],
        ],
      ),
    );
  }

  /// 构建图表
  Widget _buildChart(ThemeData theme) {
    switch (widget.type) {
      case ChartType.line:
        return _buildLineChart(theme);
      case ChartType.bar:
        return _buildBarChart(theme);
      case ChartType.pie:
        return _buildPieChart(theme);
      case ChartType.scatter:
        return _buildScatterChart(theme);
      case ChartType.radar:
        return _buildRadarChart(theme);
    }
  }

  /// 构建折线图
  Widget _buildLineChart(ThemeData theme) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: widget.showGrid,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: widget.gridColor ?? theme.dividerColor,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: widget.gridColor ?? theme.dividerColor,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: widget.xAxisTitle != null
                ? Text(widget.xAxisTitle!)
                : null,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    value.toString(),
                    style: widget.textStyle ?? theme.textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: widget.yAxisTitle != null
                ? Text(widget.yAxisTitle!)
                : null,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    value.toString(),
                    style: widget.textStyle ?? theme.textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: widget.gridColor ?? theme.dividerColor,
          ),
        ),
        lineBarsData: widget.series.map((series) {
          return LineChartBarData(
            spots: series.data.map((point) {
              return FlSpot(
                point.x is num ? point.x.toDouble() : 0,
                point.y,
              );
            }).toList(),
            isCurved: true,
            color: series.color ?? theme.colorScheme.primary,
            barWidth: series.lineWidth ?? 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: series.showPoints ?? true,
            ),
            belowBarData: BarAreaData(
              show: series.showArea ?? false,
              color: series.color?.withOpacity(0.2) ??
                  theme.colorScheme.primary.withOpacity(0.2),
              gradient: series.gradientColors != null
                  ? LinearGradient(
                      colors: series.gradientColors!
                          .map((color) => color.withOpacity(0.2))
                          .toList(),
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : null,
            ),
          );
        }).toList(),
        lineTouchData: LineTouchData(
          enabled: widget.showTooltip,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: theme.cardColor,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final series = widget.series[spot.barIndex];
                return LineTooltipItem(
                  '${series.name}: ${spot.y}',
                  TextStyle(
                    color: series.color ?? theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  /// 构建柱状图
  Widget _buildBarChart(ThemeData theme) {
    return BarChart(
      BarChartData(
        gridData: FlGridData(
          show: widget.showGrid,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: widget.gridColor ?? theme.dividerColor,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: widget.gridColor ?? theme.dividerColor,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: widget.xAxisTitle != null
                ? Text(widget.xAxisTitle!)
                : null,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    value.toString(),
                    style: widget.textStyle ?? theme.textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: widget.yAxisTitle != null
                ? Text(widget.yAxisTitle!)
                : null,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    value.toString(),
                    style: widget.textStyle ?? theme.textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: widget.gridColor ?? theme.dividerColor,
          ),
        ),
        barGroups: widget.series.asMap().entries.map((entry) {
          final series = entry.value;
          return series.data.asMap().entries.map((dataEntry) {
            final point = dataEntry.value;
            return BarChartGroupData(
              x: point.x is num ? point.x.toInt() : dataEntry.key,
              barRods: [
                BarChartRodData(
                  toY: point.y,
                  color: point.color ?? series.color ?? theme.colorScheme.primary,
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList();
        }).expand((element) => element).toList(),
        barTouchData: BarTouchData(
          enabled: widget.showTooltip,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: theme.cardColor,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final series = widget.series[rodIndex];
              return BarTooltipItem(
                '${series.name}: ${rod.toY}',
                TextStyle(
                  color: rod.color ?? theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// 构建饼图
  Widget _buildPieChart(ThemeData theme) {
    return PieChart(
      PieChartData(
        sectionsSpace: 0,
        centerSpaceRadius: 40,
        sections: widget.series.first.data.asMap().entries.map((entry) {
          final point = entry.value;
          final isTouched = entry.key == _touchedIndex;
          final radius = isTouched ? 110.0 : 100.0;
          
          return PieChartSectionData(
            color: point.color ?? theme.colorScheme.primary,
            value: point.y,
            title: point.label ?? '${point.y}',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: isTouched ? 25 : 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimary,
            ),
          );
        }).toList(),
        pieTouchData: PieTouchData(
          enabled: widget.showTooltip,
          touchCallback: (event, response) {
            setState(() {
              if (response?.touchedSection != null) {
                _touchedIndex = response!.touchedSection!.touchedSectionIndex;
              } else {
                _touchedIndex = -1;
              }
            });
          },
        ),
      ),
    );
  }

  /// 构建散点图
  Widget _buildScatterChart(ThemeData theme) {
    return ScatterChart(
      ScatterChartData(
        scatterSpots: widget.series.asMap().entries.map((entry) {
          final series = entry.value;
          return series.data.map((point) {
            return ScatterSpot(
              point.x is num ? point.x.toDouble() : 0,
              point.y,
              color: point.color ?? series.color ?? theme.colorScheme.primary,
            );
          }).toList();
        }).expand((element) => element).toList(),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: widget.xAxisTitle != null
                ? Text(widget.xAxisTitle!)
                : null,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    value.toString(),
                    style: widget.textStyle ?? theme.textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: widget.yAxisTitle != null
                ? Text(widget.yAxisTitle!)
                : null,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    value.toString(),
                    style: widget.textStyle ?? theme.textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: widget.gridColor ?? theme.dividerColor,
          ),
        ),
        gridData: FlGridData(
          show: widget.showGrid,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: widget.gridColor ?? theme.dividerColor,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: widget.gridColor ?? theme.dividerColor,
              strokeWidth: 1,
            );
          },
        ),
        scatterTouchData: ScatterTouchData(
          enabled: widget.showTooltip,
          touchTooltipData: ScatterTouchTooltipData(
            tooltipBgColor: theme.cardColor,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return ScatterTooltipItem(
                  'X: ${spot.x}, Y: ${spot.y}',
                  TextStyle(
                    color: spot.color ?? theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  /// 构建雷达图
  Widget _buildRadarChart(ThemeData theme) {
    return RadarChart(
      RadarChartData(
        radarTouchData: RadarTouchData(
          enabled: widget.showTooltip,
          touchCallback: (event, response) {
            setState(() {
              if (response?.touchedSpot != null) {
                _touchedIndex = response!.touchedSpot!.touchedSpotIndex;
              } else {
                _touchedIndex = -1;
              }
            });
          },
        ),
        dataSets: widget.series.map((series) {
          return RadarDataSet(
            dataEntries: series.data.map((point) {
              return RadarEntry(value: point.y);
            }).toList(),
            fillColor: (series.color ?? theme.colorScheme.primary).withOpacity(0.2),
            borderColor: series.color ?? theme.colorScheme.primary,
            entryRadius: 3,
            borderWidth: 2,
          );
        }).toList(),
        radarShape: RadarShape.polygon,
        radarBorderData: BorderSide(
          color: widget.gridColor ?? theme.dividerColor,
        ),
        tickBorderData: BorderSide(
          color: widget.gridColor ?? theme.dividerColor,
        ),
        gridBorderData: BorderSide(
          color: widget.gridColor ?? theme.dividerColor,
          width: 2,
        ),
        ticksTextStyle: widget.textStyle ?? theme.textTheme.bodySmall!,
        titleTextStyle: widget.textStyle?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ) ?? theme.textTheme.titleSmall!,
        titlePositionPercentageOffset: 0.2,
        getTitle: (index) {
          final point = widget.series.first.data[index];
          return point.label ?? '';
        },
      ),
    );
  }

  /// 构建图例
  Widget _buildLegend(ThemeData theme) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: widget.series.map((series) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: series.color ?? theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              series.name,
              style: widget.textStyle ?? theme.textTheme.bodySmall,
            ),
          ],
        );
      }).toList(),
    );
  }
} 