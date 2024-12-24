import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../services/budget_alert_service.dart';
import '../services/budget_service.dart';
import '../services/category_budget_service.dart';
import '../services/periodic_budget_service.dart';

class BudgetAlertScreen extends StatefulWidget {
  const BudgetAlertScreen({Key? key}) : super(key: key);

  @override
  _BudgetAlertScreenState createState() => _BudgetAlertScreenState();
}

class _BudgetAlertScreenState extends State<BudgetAlertScreen> {
  final BudgetAlertService _alertService = BudgetAlertService();
  final BudgetService _budgetService = BudgetService();
  final CategoryBudgetService _categoryBudgetService = CategoryBudgetService();
  final PeriodicBudgetService _periodicBudgetService = PeriodicBudgetService();
  List<BudgetAlert> _alerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() => _isLoading = true);
    try {
      final alerts = await _alertService.getActive();
      setState(() {
        _alerts = alerts;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载预警失败: ${e.toString()}')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<String?> _getBudgetName(String budgetId, String budgetType) async {
    try {
      switch (budgetType) {
        case 'general':
          final budget = await _budgetService.get(budgetId);
          return budget?.name;
        case 'category':
          final budget = await _categoryBudgetService.get(budgetId);
          return budget != null ? '分类预算 #${budget.id}' : null;
        case 'periodic':
          final budget = await _periodicBudgetService.get(budgetId);
          return budget?.name;
        default:
          return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> _showAddEditAlertDialog([BudgetAlert? alert]) async {
    String? selectedBudgetId = alert?.budgetId;
    String budgetType = alert?.budgetType ?? 'general';
    double threshold = alert?.threshold ?? 80;
    String message = alert?.message ?? '';

    final budgets = await _budgetService.getAll();
    final categoryBudgets = await _categoryBudgetService.getAll();
    final periodicBudgets = await _periodicBudgetService.getAll();

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(alert == null ? '添加预算预警' : '编辑预算预警'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: budgetType,
                items: const [
                  DropdownMenuItem(value: 'general', child: Text('总预算')),
                  DropdownMenuItem(value: 'category', child: Text('分类预算')),
                  DropdownMenuItem(value: 'periodic', child: Text('周期预算')),
                ],
                onChanged: (value) {
                  budgetType = value!;
                  selectedBudgetId = null;
                },
                decoration: const InputDecoration(labelText: '预算类型'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedBudgetId,
                items: [
                  if (budgetType == 'general')
                    ...budgets.map((b) => DropdownMenuItem(
                          value: b.id,
                          child: Text(b.name),
                        )),
                  if (budgetType == 'category')
                    ...categoryBudgets.map((b) => DropdownMenuItem(
                          value: b.id,
                          child: Text('分类预算 #${b.id}'),
                        )),
                  if (budgetType == 'periodic')
                    ...periodicBudgets.map((b) => DropdownMenuItem(
                          value: b.id,
                          child: Text(b.name),
                        )),
                ],
                onChanged: (value) => selectedBudgetId = value,
                decoration: const InputDecoration(labelText: '选择预算'),
              ),
              Slider(
                value: threshold,
                min: 0,
                max: 100,
                divisions: 20,
                label: '${threshold.round()}%',
                onChanged: (value) => setState(() => threshold = value),
              ),
              Text('当预算使用达到 ${threshold.round()}% 时提醒'),
              TextFormField(
                initialValue: message,
                decoration: const InputDecoration(labelText: '提醒消息（可选）'),
                onChanged: (value) => message = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              if (selectedBudgetId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请选择预算')),
                );
                return;
              }

              final newAlert = BudgetAlert(
                id: alert?.id ?? const Uuid().v4(),
                budgetId: selectedBudgetId!,
                budgetType: budgetType,
                threshold: threshold,
                message: message.isEmpty ? null : message,
              );

              try {
                if (alert == null) {
                  await _alertService.create(newAlert);
                } else {
                  await _alertService.update(newAlert);
                }
                Navigator.pop(context);
                _loadAlerts();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('保存失败: ${e.toString()}')),
                );
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('预算预警管理'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _alerts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('暂无预算预警'),
                      ElevatedButton(
                        onPressed: _showAddEditAlertDialog,
                        child: const Text('添加预警'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _alerts.length,
                  itemBuilder: (context, index) {
                    final alert = _alerts[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: FutureBuilder<String?>(
                          future: _getBudgetName(alert.budgetId, alert.budgetType),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(snapshot.data!);
                            }
                            return const Text('加载中...');
                          },
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('触发阈值: ${alert.threshold.round()}%'),
                            if (alert.message != null) Text('提醒消息: ${alert.message}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: alert.isEnabled,
                              onChanged: (value) async {
                                await _alertService.toggleAlert(alert.id, value);
                                _loadAlerts();
                              },
                            ),
                            PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('编辑'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('删除'),
                                ),
                              ],
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  await _showAddEditAlertDialog(alert);
                                } else if (value == 'delete') {
                                  await _alertService.delete(alert.id);
                                  _loadAlerts();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEditAlertDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
} 