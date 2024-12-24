import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_export_import_provider.dart';
import 'package:intl/intl.dart';

/// 备份列表视图
class BackupListView extends StatelessWidget {
  final Function(String) onRestore;
  final Function(String) onDelete;

  const BackupListView({
    Key? key,
    required this.onRestore,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DataExportImportProvider>(
      builder: (context, provider, child) {
        return FutureBuilder<List<BackupInfo>>(
          future: provider.getBackupList(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48.0, color: Colors.red),
                    SizedBox(height: 16.0),
                    Text('加载备份列表失败：${snapshot.error}'),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        provider.refreshBackupList();
                      },
                      child: Text('重试'),
                    ),
                  ],
                ),
              );
            }

            final backups = snapshot.data ?? [];
            if (backups.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.backup_outlined, size: 48.0, color: Colors.grey),
                    SizedBox(height: 16.0),
                    Text('暂无备份'),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => provider.refreshBackupList(),
              child: ListView.builder(
                itemCount: backups.length,
                itemBuilder: (context, index) {
                  final backup = backups[index];
                  return _BackupListItem(
                    backup: backup,
                    onRestore: () => onRestore(backup.path),
                    onDelete: () => onDelete(backup.path),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

/// 备份列表项
class _BackupListItem extends StatelessWidget {
  final BackupInfo backup;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const _BackupListItem({
    Key? key,
    required this.backup,
    required this.onRestore,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () => _showBackupDetails(context),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.backup, color: theme.primaryColor),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          backup.name,
                          style: theme.textTheme.titleMedium,
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          '创建时间：${dateFormat.format(backup.timestamp)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'restore':
                          onRestore();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'restore',
                        child: ListTile(
                          leading: Icon(Icons.restore),
                          title: Text('恢复'),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete),
                          title: Text('删除'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (backup.description != null) ...[
                SizedBox(height: 8.0),
                Text(
                  backup.description!,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showBackupDetails(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '备份详情',
              style: theme.textTheme.titleLarge,
            ),
            SizedBox(height: 16.0),
            _DetailItem(
              icon: Icons.drive_file_rename_outline,
              label: '备份名称',
              value: backup.name,
            ),
            _DetailItem(
              icon: Icons.access_time,
              label: '创建时间',
              value: dateFormat.format(backup.timestamp),
            ),
            _DetailItem(
              icon: Icons.info_outline,
              label: '版本',
              value: backup.version,
            ),
            if (backup.description != null)
              _DetailItem(
                icon: Icons.description_outlined,
                label: '描述',
                value: backup.description!,
              ),
            _DetailItem(
              icon: Icons.folder_outlined,
              label: '文件路径',
              value: backup.path,
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('关闭'),
                ),
                SizedBox(width: 16.0),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onRestore();
                  },
                  icon: Icon(Icons.restore),
                  label: Text('恢复此备份'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 详情项
class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20.0, color: theme.colorScheme.secondary),
          SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall,
                ),
                SizedBox(height: 4.0),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 