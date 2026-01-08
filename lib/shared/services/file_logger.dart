import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

class FileLogger {
  static final FileLogger _instance = FileLogger._internal();
  factory FileLogger() => _instance;
  FileLogger._internal();

  static File? _logFile;
  static bool _isInitialized = false;

  // Initialize logger and create log file
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final directory = await _getLogDirectory();
      final timestamp = DateFormat('yyyyMMdd').format(DateTime.now());
      final logFileName = 'ultra_pos_$timestamp.log';
      _logFile = File(p.join(directory.path, logFileName));

      // Create if doesn't exist
      if (!await _logFile!.exists()) {
        await _logFile!.create(recursive: true);
        await log('═' * 60);
        await log('Ultra Pos Application Log');
        await log('Started: ${DateTime.now()}');
        await log('═' * 60);
      }

      _isInitialized = true;
      debugPrint('[FileLogger] Initialized at: ${_logFile!.path}');

      // Clean old logs (keep last 7 days)
      await _cleanOldLogs(directory);
    } catch (e, stack) {
      debugPrint('[FileLogger] Initialization failed: $e\n$stack');
    }
  }

  // Get log directory based on platform
  Future<Directory> _getLogDirectory() async {
    if (Platform.isWindows) {
      // For Windows, use executable directory/logs
      final exePath = Platform.resolvedExecutable;
      final exeDir = p.dirname(exePath);
      final logDir = Directory(p.join(exeDir, 'logs'));
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }
      return logDir;
    } else {
      // For mobile, use documents directory
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory(p.join(directory.path, 'logs'));
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }
      return logDir;
    }
  }

  // Clean old log files
  Future<void> _cleanOldLogs(Directory logDir) async {
    try {
      final now = DateTime.now();
      await for (final entity in logDir.list()) {
        if (entity is File && p.extension(entity.path) == '.log') {
          final stat = await entity.stat();
          if (now.difference(stat.modified).inDays > 7) {
            await entity.delete();
            debugPrint(
              '[FileLogger] Deleted old log: ${p.basename(entity.path)}',
            );
          }
        }
      }
    } catch (e) {
      debugPrint('[FileLogger] Error cleaning old logs: $e');
    }
  }

  // Write a log entry with timestamp
  Future<void> log(String message, {String level = 'INFO'}) async {
    try {
      if (!_isInitialized) await init();
      if (_logFile == null) return;

      final timestamp = DateFormat(
        'yyyy-MM-dd HH:mm:ss.SSS',
      ).format(DateTime.now());
      final logEntry = '[$timestamp][$level] $message\n';

      // Also print to console
      debugPrint(logEntry.trim());

      // Write to file
      await _logFile!.writeAsString(
        logEntry,
        mode: FileMode.append,
        flush: true,
      );
    } catch (e) {
      debugPrint('[FileLogger] Failed to write log: $e');
    }
  }

  // Log error with stack trace
  Future<void> logError(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) async {
    await log('ERROR: $message', level: 'ERROR');
    if (error != null) {
      await log('Details: $error', level: 'ERROR');
    }
    if (stackTrace != null) {
      await log('Stack trace:\n$stackTrace', level: 'ERROR');
    }
  }

  // Read all logs (for debugging)
  Future<String> readLogs() async {
    if (_logFile == null) await init();
    if (_logFile == null || !await _logFile!.exists()) return '';
    return await _logFile!.readAsString();
  }

  // Clear logs (optional)
  Future<void> clearLogs() async {
    if (_logFile == null) await init();
    if (_logFile != null && await _logFile!.exists()) {
      await _logFile!.writeAsString('');
    }
  }

  // Get log file path
  String? get logFilePath => _logFile?.path;
}
