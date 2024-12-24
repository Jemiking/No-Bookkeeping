import 'package:flutter/material.dart';

class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<GuidePageData> _pages = [
    GuidePageData(
      image: Icons.account_balance_wallet,
      title: '轻松记账',
      subtitle: '让生活更有规划',
    ),
    GuidePageData(
      image: Icons.analytics,
      title: '智能分析',
      subtitle: '了解你的消费习惯',
    ),
    GuidePageData(
      image: Icons.security,
      title: '安全可靠',
      subtitle: '数据安全有保障',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 页面内容
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return GuidePage(data: _pages[index]);
            },
          ),
          // 页面指示器
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: CircleAvatar(
                    radius: 4,
                    backgroundColor: _currentPage == index
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          // 下一步按钮
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                if (_currentPage < _pages.length - 1) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  // TODO: 导航到登录页面
                }
              },
              child: Text(_currentPage < _pages.length - 1 ? '下一步' : '开始使用'),
            ),
          ),
        ],
      ),
    );
  }
}

class GuidePage extends StatelessWidget {
  final GuidePageData data;

  const GuidePage({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          data.image,
          size: 120,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 40),
        Text(
          data.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          data.subtitle,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class GuidePageData {
  final IconData image;
  final String title;
  final String subtitle;

  GuidePageData({
    required this.image,
    required this.title,
    required this.subtitle,
  });
} 