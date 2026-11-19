import 'package:intl/intl.dart';

/// Formatting utility for timestamps across shifts, receipts, and ledger items
class DateFormatter {
  static final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat _shortDateFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final DateFormat _receiptFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _orderNumDateFormat = DateFormat('yyyyMMdd');

  static String formatFull(DateTime dt) => _dateTimeFormat.format(dt);
  static String formatShort(DateTime dt) => _shortDateFormat.format(dt);
  static String formatTime(DateTime dt) => _timeFormat.format(dt);
  static String formatReceipt(DateTime dt) => _receiptFormat.format(dt);
  static String formatOrderPrefix(DateTime dt) => _orderNumDateFormat.format(dt);

  /// Human relative time (e.g. "5m ago", "Today", "Yesterday")
  static String formatRelative(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24 && dt.day == now.day) {
      return 'Today, ${_timeFormat.format(dt)}';
    } else if (difference.inDays < 2) {
      return 'Yesterday, ${_timeFormat.format(dt)}';
    } else {
      return _shortDateFormat.format(dt);
    }
  }
}
