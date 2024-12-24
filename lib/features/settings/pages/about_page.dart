import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 应用 Logo
          Center(
            child: Container(
              width: 100,
              height: 100,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: AssetImage('assets/images/app_logo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          
          // 应用名称和版本
          Center(
            child: Text(
              _packageInfo?.appName ?? 'Money Tracker',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Version ${_packageInfo?.version ?? '1.0.0'} (${_packageInfo?.buildNumber ?? '1'})',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 应用介绍
          const Text(
            '这是一款现代化的个人记账软件，致力于提供简单易用、功能强大的记账解决方案。',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          
          const SizedBox(height: 32),
          
          // 功能列表
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    '主要功能',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet),
                  title: const Text('多账户管理'),
                  subtitle: const Text('支持多种账户类型，灵活管理资金'),
                ),
                ListTile(
                  leading: const Icon(Icons.category),
                  title: const Text('分类与标签'),
                  subtitle: const Text('自定义分类和标签，清晰记录每笔支出'),
                ),
                ListTile(
                  leading: const Icon(Icons.insert_chart),
                  title: const Text('数据统计'),
                  subtitle: const Text('多维度数据分析，了解消费习惯'),
                ),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('数据安全'),
                  subtitle: const Text('本地存储，安全可靠'),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 开发者信息
          Card(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    '开发者信息',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('联系我们'),
                  subtitle: const Text('support@moneytracker.com'),
                  onTap: () => _launchUrl('mailto:support@moneytracker.com'),
                ),
                ListTile(
                  leading: const Icon(Icons.web),
                  title: const Text('官方网站'),
                  subtitle: const Text('www.moneytracker.com'),
                  onTap: () => _launchUrl('https://www.moneytracker.com'),
                ),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('开源地址'),
                  subtitle: const Text('GitHub'),
                  onTap: () => _launchUrl('https://github.com/moneytracker'),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 版权信息
          const Center(
            child: Text(
              '© 2024 Money Tracker. All rights reserved.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
} 