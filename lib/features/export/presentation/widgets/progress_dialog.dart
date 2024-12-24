import 'package:flutter/material.dart';
import '../../domain/data_export_import.dart';

/// 进度对话框
class ProgressDialog extends StatelessWidget {
  final String title;
  final String message;
  final Stream<ExportProgress>? progress;

  const ProgressDialog({
    Key? key,
    required this.title,
    required this.message,
    this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16.0),
            Text(message),
            SizedBox(height: 24.0),
            if (progress != null)
              StreamBuilder<ExportProgress>(
                stream: progress,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16.0),
                        Text('准备中...'),
                      ],
                    );
                  }

                  final data = snapshot.data!;
                  return Column(
                    children: [
                      LinearProgressIndicator(
                        value: data.progress,
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        '${data.currentOperation} (${data.processedItems}/${data.totalItems})',
                      ),
                    ],
                  );
                },
              )
            else
              Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16.0),
                  Text('处理中...'),
                ],
              ),
          ],
        ),
      ),
    );
  }
} 