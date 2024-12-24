import 'package:flutter/material.dart';

class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  bool _isDarkMode = false;
  String _selectedTheme = '默认主题';
  Color _primaryColor = Colors.blue;
  double _fontSize = 14.0;

  final List<String> _presetThemes = [
    '默认主题',
    '清新绿意',
    '深邃蓝调',
    '温暖橙光',
    '优雅紫韵',
  ];

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    // TODO: 更新应用主题模式
  }

  void _updateSelectedTheme(String theme) {
    setState(() {
      _selectedTheme = theme;
    });
    // TODO: 应用选中的主题
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('选择主题色'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Colors.blue,
                    Colors.green,
                    Colors.purple,
                    Colors.orange,
                    Colors.red,
                    Colors.teal,
                    Colors.pink,
                    Colors.indigo,
                  ].map((color) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _primaryColor = color;
                        });
                        Navigator.pop(context);
                        // TODO: 应用选中的主题色
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _primaryColor == color
                                ? Colors.white
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('调整字体大小'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: _fontSize,
                min: 12.0,
                max: 20.0,
                divisions: 8,
                label: _fontSize.toString(),
                onChanged: (value) {
                  setState(() {
                    _fontSize = value;
                  });
                  // TODO: 应用字体大小设置
                },
              ),
              Text(
                '预览文本',
                style: TextStyle(fontSize: _fontSize),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                // TODO: 保存字体大小设置
                Navigator.pop(context);
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  void _resetThemeSettings() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('重置主题设置'),
          content: const Text('确定要将所有主题设置恢复为默认值吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isDarkMode = false;
                  _selectedTheme = '默认主题';
                  _primaryColor = Colors.blue;
                  _fontSize = 14.0;
                });
                // TODO: 应用默认主题设置
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已重置主题设置')),
                );
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('主题设置'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetThemeSettings,
            tooltip: '重置设置',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode),
                  title: const Text('深色模式'),
                  subtitle: const Text('切换应用的明暗主题'),
                  value: _isDarkMode,
                  onChanged: _toggleDarkMode,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.color_lens),
                  title: const Text('主题色'),
                  subtitle: const Text('选择应用的主题色'),
                  trailing: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  onTap: _showColorPicker,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '预设主题',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _presetThemes.map((theme) {
                          return ChoiceChip(
                            label: Text(theme),
                            selected: _selectedTheme == theme,
                            onSelected: (selected) {
                              if (selected) {
                                _updateSelectedTheme(theme);
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.text_fields),
                  title: const Text('字体大小'),
                  subtitle: Text('当前：${_fontSize.toStringAsFixed(1)}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showFontSizeDialog,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.style),
                  title: const Text('字体样式'),
                  subtitle: const Text('选择应用的字体'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: 实现字体样式选择功能
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette),
                  title: const Text('自定义主题'),
                  subtitle: const Text('创建和管理自定义主题'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: 实现自定义主题功能
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.share),
                  title: const Text('导出主题'),
                  subtitle: const Text('分享当前主题设置'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: 实现主题导出功能
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 