import 'package:flutter/foundation.dart';

/// 日志工具类
/// 用于替换print语句，支持不同级别的日志
class Logger {
  static const String _tag = '[Marker3]';
  
  // 存储日志的列表
  static final List<String> _logs = [];
  
  /// 调试日志
  static void d(String message) {
    if (kDebugMode) {
      final logMessage = '$_tag [DEBUG] $message';
      print(logMessage);
      _logs.add(logMessage);
    }
  }
  
  /// 信息日志
  static void i(String message) {
    if (kDebugMode) {
      final logMessage = '$_tag [INFO] $message';
      print(logMessage);
      _logs.add(logMessage);
    }
  }
  
  /// 警告日志
  static void w(String message) {
    if (kDebugMode) {
      final logMessage = '$_tag [WARN] $message';
      print(logMessage);
      _logs.add(logMessage);
    }
  }
  
  /// 错误日志
  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      final logMessage = '$_tag [ERROR] $message';
      print(logMessage);
      _logs.add(logMessage);
      
      if (error != null) {
        final errorLog = '$_tag [ERROR] Error: $error';
        print(errorLog);
        _logs.add(errorLog);
      }
      if (stackTrace != null) {
        final stackLog = '$_tag [ERROR] StackTrace: $stackTrace';
        print(stackLog);
        _logs.add(stackLog);
      }
    }
  }
  
  /// 权限状态日志
  static void logPermissionStatus(String permissionName, String status) {
    if (kDebugMode) {
      final logMessage = '$_tag [PERMISSION] $permissionName: $status';
      print(logMessage);
      _logs.add(logMessage);
    }
  }
  
  /// 获取所有日志
  static List<String> getLogs() {
    return List.from(_logs);
  }
  
  /// 获取最近的N条日志
  static List<String> getRecentLogs(int count) {
    if (_logs.length <= count) {
      return List.from(_logs);
    }
    return _logs.sublist(_logs.length - count);
  }
  
  /// 清空日志
  static void clearLogs() {
    _logs.clear();
  }
  
  /// 获取日志数量
  static int getLogCount() {
    return _logs.length;
  }
}
