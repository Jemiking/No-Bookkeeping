import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../../lib/services/security_backup_service.dart';
import '../../lib/services/database_service.dart';
import '../../lib/models/database_models.dart';
import 'security_backup_service_test.mocks.dart';

@GenerateMocks([DatabaseService])
void main() {
  late SecurityBackupService backupService;
  late MockDatabaseService mockDatabaseService;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    backupService = SecurityBackupService();
  });

  tearDown(() {
    backupService.dispose();
  });

  group('SecurityBackupService Tests', () {
    test('初始化备份服务', () async {
      final config = BackupConfig(
        backupPath: 'test_backups',
        encryptBackup: true,
        encryptionKey: 'test_key',
      );

      await backupService.init(config);
      expect(backupService.statusStream, isNotNull);
    });

    test('创建备份', () async {
      final config = BackupConfig(
        backupPath: 'test_backups',
        encryptBackup: true,
        encryptionKey: 'test_key',
      );

      await backupService.init(config);

      when(mockDatabaseService.queryAll(any)).thenAnswer((_) async => [
        {'id': 1, 'name': 'Test'}
      ]);

      when(mockDatabaseService.count(any)).thenAnswer((_) async => 1);

      final metadata = await backupService.createBackup();

      expect(metadata, isNotNull);
      expect(metadata.isEncrypted, isTrue);
      expect(metadata.isCompressed, isTrue);
    });

    test('恢复备份', () async {
      final config = BackupConfig(
        backupPath: 'test_backups',
        encryptBackup: true,
        encryptionKey: 'test_key',
      );

      await backupService.init(config);

      when(mockDatabaseService.transaction(any)).thenAnswer((_) async => null);

      await expectLater(
        backupService.restoreBackup('test_backup', encryptionKey: 'test_key'),
        completes,
      );
    });

    test('获取备份列表', () async {
      final config = BackupConfig(
        backupPath: 'test_backups',
        encryptBackup: true,
        encryptionKey: 'test_key',
      );

      await backupService.init(config);

      final backups = await backupService.getBackupList();
      expect(backups, isA<List<BackupMetadata>>());
    });

    test('删除备份', () async {
      final config = BackupConfig(
        backupPath: 'test_backups',
        encryptBackup: true,
        encryptionKey: 'test_key',
      );

      await backupService.init(config);

      await expectLater(
        backupService.deleteBackup('test_backup'),
        completes,
      );
    });
  });
} 