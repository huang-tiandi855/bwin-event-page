class DateTimeUtil {
  ///日期时间本地格式化
  static String utc2iso(String? formattedString) {
    if (formattedString == null || formattedString.isEmpty) return '';
    try {
      DateTime dateTime = DateTime.parse(formattedString).toLocal();
      String? y = _fourDigits(dateTime.year);
      String? m = _twoDigits(dateTime.month);
      String? d = _twoDigits(dateTime.day);
      String? h = _twoDigits(dateTime.hour);
      String? min = _twoDigits(dateTime.minute);
      String? sec = _twoDigits(dateTime.second);
      return "$y-$m-$d $h:$min:$sec";
    } catch (e) {
      return '';
    }
  }

  ///日期时间本地格式化
  static String utc2isoMD(String? formattedString) {
    if (formattedString == null || formattedString.isEmpty) return '';
    try {
      DateTime dateTime = DateTime.parse(formattedString).toLocal();
      String? m = _twoDigits(dateTime.month);
      String? d = _twoDigits(dateTime.day);
      return "$m月$d日";
    } catch (e) {
      return '';
    }
  }

  ///2020-11-26T17:44:45.000Z
  static String? format2utc(DateTime dateTime) {
    String? y = _fourDigits(dateTime.year);
    String? m = _twoDigits(dateTime.month);
    String? d = _twoDigits(dateTime.day);
    String? h = _twoDigits(dateTime.hour);
    String? min = _twoDigits(dateTime.minute);
    String? sec = _twoDigits(dateTime.second);
    String? ms = _threeDigits(dateTime.millisecond);
    return "$y-$m-${d}T$h:$min:$sec.${ms}Z";
  }

  static String? _fourDigits(int n) {
    int absN = n.abs();
    String? sign = n < 0 ? "-" : "";
    if (absN >= 1000) return "$n";
    if (absN >= 100) return "${sign}0$absN";
    if (absN >= 10) return "${sign}00$absN";
    return "${sign}000$absN";
  }

  static String? _threeDigits(int n) {
    if (n >= 100) return "$n";
    if (n >= 10) return "0$n";
    return "00$n";
  }

  static String? _twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  ///utc 转 年月日
  static String utcTurnYear(String? date,
      {String? char, bool? isChina, bool showHM = false}) {
    if (date == null || date.isEmpty) return '';
    String? gap = char ?? "-";
    DateTime dateTime = DateTime.parse(date).toLocal();
    String? y = _fourDigits(dateTime.year);
    String? m = _twoDigits(dateTime.month);
    String? d = _twoDigits(dateTime.day);
    String? hour = _twoDigits(dateTime.hour);
    String? min = _twoDigits(dateTime.minute);
    if (isChina == true) {
      return "$y年$m月$d日";
    }
    if (showHM == true) {
      return "$y$gap$m$gap$d $hour:$min";
    }
    return "$y$gap$m$gap$d ";
  }

  /// 毫秒时间戳 → `"yyyy{char}MM{char}dd"`。
  ///
  /// 兼容当前服务端把 `createdAt / updatedAt` 同时落成以下三种形态的现状：
  /// - 数值毫秒：`1779966835000`；
  /// - 字符串毫秒：`"1779966835000"`（model 端常做了 `?.toString()`）；
  /// - ISO 字符串：`"2024-08-14T08:48:14.447Z"`。
  ///
  /// 解析优先级：先按毫秒数字处理（int / num / 纯数字字符串），失败再
  /// fallback 到 [DateTime.parse]，再失败返回 [defaultValue]，永不抛异常，
  /// 方便直接挂在列表 cell 上而不需要在调用方再包 try-catch。
  ///
  /// [char] 用来切分 y / m / d，默认 `-`；如需中文 "y年m月d日" 仍走
  /// [utcTurnYear]（那条只接受 ISO 字符串）。
  static String timestamp2YearMonthDay(
    dynamic raw, {
    String char = '-',
    String defaultValue = '',
  }) {
    if (raw == null) return defaultValue;
    DateTime? dt;
    if (raw is num) {
      dt = DateTime.fromMillisecondsSinceEpoch(raw.toInt()).toLocal();
    } else if (raw is String) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) return defaultValue;
      final asInt = int.tryParse(trimmed);
      if (asInt != null) {
        dt = DateTime.fromMillisecondsSinceEpoch(asInt).toLocal();
      } else {
        try {
          dt = DateTime.parse(trimmed).toLocal();
        } catch (_) {
          return defaultValue;
        }
      }
    } else {
      return defaultValue;
    }
    final y = _fourDigits(dt.year);
    final m = _twoDigits(dt.month);
    final d = _twoDigits(dt.day);
    return '$y$char$m$char$d';
  }

  ///utc 转 月日
  static String? utc2MonthDay(String? date) {
    if (date == null || date.isEmpty) return '';
    try {
      DateTime dateTime = DateTime.parse(date).toLocal();
      String? m = _twoDigits(dateTime.month);
      String? d = _twoDigits(dateTime.day);
      return "$m-$d ";
    } catch (e) {
      return '';
    }
  }

  ///utc 转 时、分
  static String? utc2HourMinute(String? date) {
    if (date == null || date.isEmpty) return '';
    try {
      DateTime dateTime = DateTime.parse(date).toLocal();
      String? h = _twoDigits(dateTime.hour);
      String? m = _twoDigits(dateTime.minute);
      return "$h-$m ";
    } catch (e) {
      return '';
    }
  }

  static String utc3YearMonthDay(DateTime dateTime) {
    try {
      String? y = _twoDigits(dateTime.year);
      String? m = _twoDigits(dateTime.month);
      String? d = _twoDigits(dateTime.day);
      return "$y-$m-$d ";
    } catch (e) {
      return '';
    }
  }

  ///计算时间差值
  static String? calTime(String? date, DateTime? serverTime) {
    //解析时间
    var time = DateTime.parse(date ?? "").toLocal();
    //计算时间差
    var difference = time.difference(serverTime ?? DateTime.now());

    String? day = difference.inDays.toString();
    String? hours = (difference.inHours % 24).toString();
    String? minutes = (difference.inMinutes % 60).toString();
    return "${day}_${hours}_$minutes";
  }

  static String? futureTime(int seconds) {
    //解析时间
    DateTime date = DateTime.now();
    DateTime dateFuture = date.add(Duration(seconds: seconds));
    String? y = _fourDigits(dateFuture.year);
    String? m = _twoDigits(dateFuture.month);
    String? d = _twoDigits(dateFuture.day);
    String? hour = _twoDigits(dateFuture.hour);
    String? min = _twoDigits(dateFuture.minute);
    String? sec = _twoDigits(dateFuture.second);
    return "$y-$m-$d $hour:$min:$sec";
  }

  static String? formatDuration(Duration position) {
    final ms = position.inMilliseconds;

    int seconds = ms ~/ 1000;
    final int hours = seconds ~/ 3600;
    seconds = seconds % 3600;
    var minutes = seconds ~/ 60;
    seconds = seconds % 60;

    final hoursString = hours >= 10
        ? '$hours'
        : hours == 0
            ? '00'
            : '0$hours';

    final minutesString = minutes >= 10
        ? '$minutes'
        : minutes == 0
            ? '00'
            : '0$minutes';

    final secondsString = seconds >= 10
        ? '$seconds'
        : seconds == 0
            ? '00'
            : '0$seconds';

    final formattedTime =
        '${hoursString == '00' ? '' : '$hoursString:'}$minutesString:$secondsString';

    return formattedTime;
  }

  static bool inTime(String startTime, String endTime) {
    DateTime now = DateTime.now();
    var sTime = DateTime.parse(utc2iso(startTime)).toLocal();
    var eTime = DateTime.parse(utc2iso(endTime)).toLocal();

    bool inTime = now.isAfter(sTime) && now.isBefore(eTime);
    return inTime;
  }

  ///计算当前时间差值
  static int calTime4(String startDate) {
    var time = DateTime.parse(utc2iso(startDate)).toLocal();
    //计算时间差
    var difference = DateTime.now().difference(time);
    return difference.inSeconds;
  }

  static int calTime3(String date) {
    //解析时间
    var time = DateTime.parse(utc2iso(date)).toLocal();
    //计算时间差
    var difference = time.difference(DateTime.now());
    return difference.inSeconds;
  }
}

/// 构建时分秒`00:00:00`
String buildHHMMSS(int seconds) {
  int hour = seconds ~/ 3600;
  int minute = (seconds ~/ 60) % 60;
  int second = seconds % 60;
  return "${_formatTime(hour)}:${_formatTime(minute)}:${_formatTime(second)}";
}

/// 构建分秒`00:00:00`
String buildMMSS(int seconds) {
  int minute = seconds ~/ 60;
  int second = seconds % 60;
  return "${_formatTime(minute)}:${_formatTime(second)}";
}

//数字格式化，将 0~9 的时间转换为 00~09
String _formatTime(int timeNum) {
  return timeNum < 10 ? "0$timeNum" : timeNum.toString();
}
