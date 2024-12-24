import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'custom_theme.dart';
import 'theme_manager.dart';

class ThemeSelectorScreen extends StatefulWidget {
  const ThemeSelectorScreen({super.key});

  @override
  State<ThemeSelectorScreen> createState() => _ThemeSelectorScreenState();
}

class _ThemeSelectorScreenState extends State<ThemeSelectorScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('主题设置'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '预设主题'),
              Tab(text: '自定义主题'),
              Tab(text: '创建主题'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPresetThemes(),
            _buildCustomThemes(),
            _buildThemeCreator(),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetThemes() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('系���主题', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildThemeOption('浅色模式', 'light'),
        _buildThemeOption('深色模式', 'dark'),
        const Divider(height: 32),
        const Text('预设主题', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...CustomTheme.presetThemes.map((theme) => _buildPresetThemeOption(theme)),
      ],
    );
  }

  Widget _buildCustomThemes() {
    final customThemes = context.watch<ThemeManager>().customThemes;
    
    if (customThemes.isEmpty) {
      return const Center(
        child: Text('暂无自定义主题'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: customThemes.length,
      itemBuilder: (context, index) {
        final entry = customThemes.entries.elementAt(index);
        return _buildCustomThemeOption(entry.key, entry.value);
      },
    );
  }

  Widget _buildThemeCreator() {
    return const ThemeCreatorForm();
  }

  Widget _buildThemeOption(String name, String themeName) {
    final themeManager = context.watch<ThemeManager>();
    final isSelected = themeManager.currentTheme == 
        (themeName == 'light' ? ThemeData.light() : ThemeData.dark());

    return ListTile(
      title: Text(name),
      trailing: isSelected ? const Icon(Icons.check) : null,
      onTap: () {
        context.read<ThemeManager>().switchToPresetTheme(themeName);
      },
    );
  }

  Widget _buildPresetThemeOption(CustomTheme theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: theme.primaryColor),
        title: Text(theme.name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.preview),
              onPressed: () {
                _previewTheme(theme);
              },
            ),
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                _applyPresetTheme(theme);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomThemeOption(String name, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.preview),
              onPressed: () {
                _previewTheme(theme);
              },
            ),
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                context.read<ThemeManager>().switchToCustomTheme(name);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _deleteCustomTheme(name);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _previewTheme(dynamic theme) {
    // TODO: 实现主题预览功能
  }

  void _applyPresetTheme(CustomTheme theme) {
    final themeManager = context.read<ThemeManager>();
    themeManager.createCustomTheme(theme.name, theme.toThemeData());
    themeManager.switchToCustomTheme(theme.name);
  }

  void _deleteCustomTheme(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除主题'),
        content: Text('确定要删除主题"$name"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              context.read<ThemeManager>().deleteCustomTheme(name);
              Navigator.pop(context);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

class ThemeCreatorForm extends StatefulWidget {
  const ThemeCreatorForm({super.key});

  @override
  State<ThemeCreatorForm> createState() => _ThemeCreatorFormState();
}

class _ThemeCreatorFormState extends State<ThemeCreatorForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  Color _primaryColor = Colors.blue;
  Color _secondaryColor = Colors.blueAccent;
  Color _backgroundColor = Colors.white;
  Color _surfaceColor = Colors.white;
  Color _textColor = Colors.black87;
  double _borderRadius = 8.0;
  double _elevation = 2.0;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '主题名称',
                hintText: '请输入主题名称',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入主题名称';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            const Text('主色调', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            _buildColorPicker(_primaryColor, (color) {
              setState(() => _primaryColor = color);
            }),
            const SizedBox(height: 16),
            const Text('次要色调', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            _buildColorPicker(_secondaryColor, (color) {
              setState(() => _secondaryColor = color);
            }),
            const SizedBox(height: 16),
            const Text('背景色', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            _buildColorPicker(_backgroundColor, (color) {
              setState(() => _backgroundColor = color);
            }),
            const SizedBox(height: 16),
            const Text('表面色', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            _buildColorPicker(_surfaceColor, (color) {
              setState(() => _surfaceColor = color);
            }),
            const SizedBox(height: 16),
            const Text('文本色', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            _buildColorPicker(_textColor, (color) {
              setState(() => _textColor = color);
            }),
            const SizedBox(height: 24),
            const Text('圆角半径', style: TextStyle(fontSize: 16)),
            Slider(
              value: _borderRadius,
              min: 0,
              max: 32,
              divisions: 32,
              label: _borderRadius.round().toString(),
              onChanged: (value) {
                setState(() => _borderRadius = value);
              },
            ),
            const SizedBox(height: 16),
            const Text('阴影高度', style: TextStyle(fontSize: 16)),
            Slider(
              value: _elevation,
              min: 0,
              max: 16,
              divisions: 16,
              label: _elevation.round().toString(),
              onChanged: (value) {
                setState(() => _elevation = value);
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveTheme,
                child: const Text('保存主题'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker(Color currentColor, ValueChanged<Color> onColorChanged) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: currentColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: 实现颜色选择器
            // 这里可以使用第三方颜色选择器插件
          },
          child: const Center(
            child: Text('点击选择颜色'),
          ),
        ),
      ),
    );
  }

  void _saveTheme() {
    if (_formKey.currentState!.validate()) {
      final theme = CustomTheme(
        name: _nameController.text,
        primaryColor: _primaryColor,
        secondaryColor: _secondaryColor,
        backgroundColor: _backgroundColor,
        surfaceColor: _surfaceColor,
        textColor: _textColor,
        borderRadius: _borderRadius,
        elevation: _elevation,
      );

      final themeManager = context.read<ThemeManager>();
      themeManager.createCustomTheme(theme.name, theme.toThemeData());
      themeManager.switchToCustomTheme(theme.name);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('主题已保存')),
      );

      Navigator.pop(context);
    }
  }
} 