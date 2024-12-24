import 'package:sqflite/sqflite.dart';
import '../core/exceptions/app_exceptions.dart';
import '../services/backup_service.dart';
import 'migrations/001_update_transactions_table.dart';

class MigrationRunner {
  final Database db;
  final BackupService _backupService;

  MigrationRunner(this.db) : _backupService = BackupService();

  Future<void> migrate(int fromVersion, int toVersion) async {
    try {
      // 创建数据库备份
      final backupPath = await _backupService.createBackup();
      print('Database backup created at: $backupPath');

      try {
        // 执行迁移
        await _executeMigrations(fromVersion, toVersion);
        print('Database migration completed successfully');
      } catch (e) {
        // 如果迁移失败，尝试恢复备份
        print('Migration failed, attempting to restore from backup');
        await _backupService.restoreFromBackup(backupPath);
        throw DatabaseException(
          'Migration failed and database was restored from backup',
          details: e.toString(),
        );
      }
    } catch (e) {
      throw DatabaseException(
        'Migration process failed',
        details: e.toString(),
      );
    }
  }

  Future<void> _executeMigrations(int fromVersion, int toVersion) async {
    // 按版本号顺序执行迁移
    if (fromVersion < 2 && toVersion >= 2) {
      print('Executing migration to version 2');
      await UpdateTransactionsTableMigration.up(db);
    }
    // 添加更多版本的迁移...
  }

  Future<void> rollback(int fromVersion, int toVersion) async {
    try {
      // 创建回滚前的备份
      final backupPath = await _backupService.createBackup();
      print('Database backup created before rollback at: $backupPath');

      try {
        // 执行回滚
        await _executeRollbacks(fromVersion, toVersion);
        print('Database rollback completed successfully');
      } catch (e) {
        // 如果回滚失败，尝试恢复备份
        print('Rollback failed, attempting to restore from backup');
        await _backupService.restoreFromBackup(backupPath);
        throw DatabaseException(
          'Rollback failed and database was restored from backup',
          details: e.toString(),
        );
      }
    } catch (e) {
      throw DatabaseException(
        'Rollback process failed',
        details: e.toString(),
      );
    }
  }

  Future<void> _executeRollbacks(int fromVersion, int toVersion) async {
    // 按版���号逆序执行回滚
    if (fromVersion >= 2 && toVersion < 2) {
      print('Rolling back from version 2');
      await UpdateTransactionsTableMigration.down(db);
    }
    // 添加更多版本的回滚...
  }
} 