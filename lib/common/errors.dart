import 'package:flutter/foundation.dart';

/// Logs an unexpected error without crashing the screen: the user sees a
/// simple message, the details stay readable during development.
void logError(Object error, StackTrace stack) {
  debugPrint('Unexpected error: $error\n$stack');
}
