import 'dart:developer';

import 'package:flutter/foundation.dart';

/// A utility class for handling debug prints and logs
class PrintLogs {
  
  static const int maxLogLength = 10000;

  static String _processMessage(dynamic message) {
    if (message == null) return 'null';
    
    if (message is String) {
      if (message.length > maxLogLength) {
        return '${message.substring(0, maxLogLength)}... (truncated ${message.length - maxLogLength} characters)';
      }
      return message;
    }
    
    final str = message.toString();
    if (str.length > maxLogLength) {
      return '${str.substring(0, maxLogLength)}... (truncated ${str.length - maxLogLength} characters)';
    }
    return str;
  }

  /// Prints a message to the console in debug mode with an optional tag
  static void printMessage(
    dynamic message, {
    String tag = 'PRINT',
  }) {
    if (kDebugMode) {
      print('[$tag] --> ${_processMessage(message)}');
    }
  }

  /// Logs a message in debug mode

  static void printLog(
    dynamic message, {
    String tag = 'LOG',
    StackTrace? stackTrace,
    Object? error,
  }) {
    if (kDebugMode) {
      log(
        '--> ${_processMessage(message)}',
        name: tag,
        stackTrace: stackTrace,
        error: error,
      );
    }
  }

  /// Prints an error message 
  static void printError(
    dynamic message, {
    Object? error,
    String tag = 'ERROR',
    StackTrace? stackTrace,
  }) {
    log(
      '--> \x1B[31m${_processMessage(message)}\x1B[0m',
      name: '\x1B[31m$tag\x1B[0m',
      error: error,
      stackTrace: stackTrace,
    );
  }


  static void logInfo(
    dynamic message, {
    String tag = 'INFO',
    StackTrace? stackTrace,
    Object? error,
  }) {
    if (kDebugMode) {
      log(
        '--> \x1B[37m${_processMessage(message)}\x1B[0m',
        name:'\x1B[33m$tag\x1B[0m',
        stackTrace: stackTrace,
      );
    }
  }


  static void logSuccess(
    dynamic message, {
    String tag = 'SUCCESS',
    StackTrace? stackTrace,
    Object? error,
  }) {
    if (kDebugMode) {
      log(
        '--> \x1B[32m${_processMessage(message)}\x1B[0m',
        name:'\x1B[32m$tag\x1B[0m',
        stackTrace: stackTrace,
      );
    }
  }


}
