import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';
import '../theme/theme_manager.dart';
import '../navigation/navigation_manager.dart';

class GuideScreen extends StatefulWidget {
  const GuideScreen({Key? key}) : super(key: key);

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<GuidePageData> _pages = [
    GuidePageData(
      title: '轻松记账',
      description: '让生活更有规划',
      icon: Icons.account_balance_wallet,
    ),
    GuidePageData(
      title: '智能分析',
      description: '了解你的消费习惯',
      icon: Icons.analytics,
    ),
    GuidePageData(
      title: '预算管理',
      description: '合理规划你的支出',
      icon: Icons.savings,
    ),
    GuidePageData(
      title: '安全可靠',
      description: '数据安全有保障',
      icon: Icons.security,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _finishGuide() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasShownGuide', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Stack(
        children: [
          // 页面视图
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return GuidePage(data: _pages[index]);
            },
          ),
          
          // 页面指示器
          Positioned(
            top: 50.0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  height: 8.0,
                  width: _currentPage == index ? 24.0 : 8.0,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? theme.primaryColor
                        : theme.primaryColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
              ),
            ),
          ),
          
          // 跳过按钮
          Positioned(
            top: 50.0,
            right: 20.0,
            child: TextButton(
              onPressed: _finishGuide,
              child: Text(
                '跳过',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
          
          // 下一步/开始按钮
          Positioned(
            bottom: 50.0,
            left: 20.0,
            right: 20.0,
            child: ElevatedButton(
              onPressed: () {
                if (_currentPage < _pages.length - 1) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  _finishGuide();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: Text(
                _currentPage < _pages.length - 1 ? '下一步' : '开始使用',
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GuidePageData {
  final String title;
  final String description;
  final IconData icon;

  GuidePageData({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class GuidePage extends StatelessWidget {
  final GuidePageData data;

  const GuidePage({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            data.icon,
            size: 120.0,
            color: theme.primaryColor,
          ),
          const SizedBox(height: 40.0),
          Text(
            data.title,
            style: TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 20.0),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.0,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
} 