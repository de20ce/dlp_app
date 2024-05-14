enum LogLevel { debug, info, warning, error }

class Logger {
  static LogLevel _logLevel = LogLevel.debug;

  static void setLogLevel(LogLevel level) {
    _logLevel = level;
  }

  static void debug(String message) {
    _log(LogLevel.debug, message);
  }

  static void info(String message) {
    _log(LogLevel.info, message);
  }

  static void warning(String message) {
    _log(LogLevel.warning, message);
  }

  static void error(String message) {
    _log(LogLevel.error, message);
  }

  static void _log(LogLevel level, String message) {
    if (level.index >= _logLevel.index) {
      final prefix = _getPrefix(level);
      print('$prefix$message');
      // You can also log to a file or send logs to a server here
    }
  }

  static String _getPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '[DEBUG] ';
      case LogLevel.info:
        return '[INFO] ';
      case LogLevel.warning:
        return '[WARNING] ';
      case LogLevel.error:
        return '[ERROR] ';
      default:
        return '';
    }
  }
}
