# Finance Manager

一个安全的个人财务管理应用。

## 功能特点

- 账户管理
- 交易记录
- 预算管理
- 分类管理
- 标签管理
- 数据备份与恢复
- 数据加密
- 安全存储

## 开发环境要求

- Flutter SDK: >=3.0.0
- Dart SDK: >=3.0.0
- Android Studio / VS Code
- Git

## 安装步骤

1. 克隆项目：
```bash
git clone https://github.com/yourusername/finance_manager.git
```

2. 安装依赖：
```bash
flutter pub get
```

3. 运行测试：
```bash
flutter test
```

4. 运行应用：
```bash
flutter run
```

## 项目结构

```
lib/
  ├── models/          # 数据模型
  ├── services/        # 服务层
  ├── utils/           # 工具类
  ├── screens/         # 界面
  ├── widgets/         # 组件
  └── main.dart        # 入口文件

test/
  ├── models/          # 模型测试
  ├── services/        # 服务测试
  └── widgets/         # 组件测试
```

## 测试

运行所有测试：
```bash
flutter test
```

运行特定测试：
```bash
flutter test test/services/database_service_test.dart
```

## 贡献指南

1. Fork 项目
2. 创建特性分支
3. 提交更改
4. 推送到分支
5. 创建 Pull Request

## 许可证

MIT License
