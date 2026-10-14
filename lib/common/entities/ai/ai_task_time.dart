/// AI 服务端时间统一按 Asia/Shanghai 展示。
///
/// 当前 Dart 标准库不包含 IANA 时区数据库；上海自 1991 年起固定为 UTC+8，
/// AI 作品均为当前业务数据，因此使用固定 UTC+8 与 H5 展示规则一致。
const Duration _shanghaiOffset = Duration(hours: 8);

/// 将 AI 任务时间解析为 UTC 时间点。
///
/// 支持：
/// - 10 位秒时间戳；
/// - 13 位毫秒时间戳；
/// - 带 `Z` / `±HH:mm` 时区的 ISO 字符串；
/// - 不带时区的上海时间字符串。
DateTime? parseAiTaskTime(Object? value) {
  if (value == null) return null;
  final String raw = value.toString().trim();
  if (raw.isEmpty) return null;

  if (RegExp(r'^\d+$').hasMatch(raw)) {
    final int? timestamp = int.tryParse(raw);
    if (timestamp == null) return null;
    final int milliseconds = raw.length <= 10 ? timestamp * 1000 : timestamp;
    return DateTime.fromMillisecondsSinceEpoch(
      milliseconds,
      isUtc: true,
    );
  }

  final bool hasTimeZone = RegExp(r'([zZ]|[+-]\d{2}:?\d{2})$').hasMatch(raw);
  if (hasTimeZone) {
    return DateTime.tryParse(raw)?.toUtc();
  }

  // 无时区字符串是服务端的上海墙钟时间。只取解析后的年月日时分秒字段，
  // 不使用设备本地时区，再减去 UTC+8 得到真正的 UTC 时间点。
  final String normalized =
      raw.contains('T') ? raw : raw.replaceFirst(' ', 'T');
  final DateTime? wallClock = DateTime.tryParse(normalized);
  if (wallClock == null) return null;
  return DateTime.utc(
    wallClock.year,
    wallClock.month,
    wallClock.day,
    wallClock.hour,
    wallClock.minute,
    wallClock.second,
    wallClock.millisecond,
    wallClock.microsecond,
  ).subtract(_shanghaiOffset);
}

String formatAiTaskDateTime(Object? value) {
  final DateTime? instant = parseAiTaskTime(value);
  if (instant == null) return '--';

  final DateTime shanghai = instant.toUtc().add(_shanghaiOffset);
  String two(int number) => number.toString().padLeft(2, '0');
  return '${shanghai.year}-${two(shanghai.month)}-${two(shanghai.day)} '
      '${two(shanghai.hour)}:${two(shanghai.minute)}:'
      '${two(shanghai.second)}';
}
