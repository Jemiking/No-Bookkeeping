import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;

class WebDAVConfig {
  final String serverUrl;
  final String username;
  final String password;
  final String basePath;
  final Duration timeout;

  WebDAVConfig({
    required this.serverUrl,
    required this.username,
    required this.password,
    this.basePath = '/money_tracker',
    this.timeout = const Duration(seconds: 30),
  });
}

class WebDAVSyncService {
  final WebDAVConfig config;
  final http.Client _client;

  WebDAVSyncService(this.config) : _client = http.Client();

  // 初始化WebDAV连接
  Future<bool> initialize() async {
    try {
      final response = await _makeRequest(
        'PROPFIND',
        config.basePath,
        depth: '0',
      );
      return response.statusCode == 207; // Multi-Status
    } catch (e) {
      return false;
    }
  }

  // 上传文件
  Future<bool> uploadFile(String localPath, String remotePath) async {
    try {
      final file = File(localPath);
      final content = await file.readAsBytes();
      final response = await _makeRequest(
        'PUT',
        path.join(config.basePath, remotePath),
        body: content,
      );
      return response.statusCode == 201 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  // 下载文件
  Future<bool> downloadFile(String remotePath, String localPath) async {
    try {
      final response = await _makeRequest(
        'GET',
        path.join(config.basePath, remotePath),
      );
      if (response.statusCode == 200) {
        final file = File(localPath);
        await file.writeAsBytes(response.bodyBytes);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // 检查文件是否存在
  Future<bool> fileExists(String remotePath) async {
    try {
      final response = await _makeRequest(
        'PROPFIND',
        path.join(config.basePath, remotePath),
        depth: '0',
      );
      return response.statusCode == 207;
    } catch (e) {
      return false;
    }
  }

  // 获取文件列表
  Future<List<String>> listFiles(String remotePath) async {
    try {
      final response = await _makeRequest(
        'PROPFIND',
        path.join(config.basePath, remotePath),
        depth: '1',
      );
      if (response.statusCode == 207) {
        // 解析XML响应获取文件列表
        // 这里需要添加XML解析逻辑
        return [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 删除文件
  Future<bool> deleteFile(String remotePath) async {
    try {
      final response = await _makeRequest(
        'DELETE',
        path.join(config.basePath, remotePath),
      );
      return response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  // 创建目录
  Future<bool> createDirectory(String remotePath) async {
    try {
      final response = await _makeRequest(
        'MKCOL',
        path.join(config.basePath, remotePath),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // 获取文件信息
  Future<Map<String, dynamic>> getFileInfo(String remotePath) async {
    try {
      final response = await _makeRequest(
        'PROPFIND',
        path.join(config.basePath, remotePath),
        depth: '0',
      );
      if (response.statusCode == 207) {
        // 解析XML响应获取文件信息
        // 这里需要添加XML解析逻辑
        return {};
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  // 发送WebDAV请求
  Future<http.Response> _makeRequest(
    String method,
    String path, {
    Object? body,
    String? depth,
  }) async {
    final uri = Uri.parse('${config.serverUrl}${path}');
    final headers = {
      'Authorization': 'Basic ${base64Encode(utf8.encode('${config.username}:${config.password}'))}',
      'Content-Type': 'application/octet-stream',
    };

    if (depth != null) {
      headers['Depth'] = depth;
    }

    final request = http.Request(method, uri)
      ..headers.addAll(headers);

    if (body != null) {
      if (body is List<int>) {
        request.bodyBytes = body;
      } else {
        request.body = body.toString();
      }
    }

    final streamedResponse = await _client.send(request);
    return await http.Response.fromStream(streamedResponse);
  }

  // 关闭客户端连接
  void dispose() {
    _client.close();
  }
} 