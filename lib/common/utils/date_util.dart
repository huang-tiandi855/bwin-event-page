import 'package:date_format/date_format.dart';

class DataFormats {
  get isEmpty => null;

  ///格式化为年月日
  static String formatDateYMD(String dateStr) {
    if (dateStr.isEmpty) {
      return "";
    }
    return formatDate(DateTime.parse(dateStr), [yyyy, '-', mm, '-', dd]);
  }

  ///格式化为时分
  static String formatDateHn(DateTime dateTime) {
    return formatDate(dateTime, [HH, ':', nn]);
  }

  ///格式化为年月日时分秒
  static String formatDateYMDHNS(String dateStr, {String char = "."}) {
    if (dateStr.isEmpty) {
      return "";
    }
    return formatDate(DateTime.parse(dateStr),
        [yyyy, char, mm, char, dd, ' ', HH, ':', nn, ':', ss]);
  }

  ///格式化为年月日时分秒
  static String formatDateHNS(String dateStr) {
    if (dateStr.isEmpty) {
      return "";
    }
    return formatDate(DateTime.parse(dateStr).toLocal(), [mm, '-', dd, ' ', HH, ':', nn, ':', ss]);
  }

  ///秒转为时分秒
  static String durationTransfromHNS(int seconds) {
    var d = Duration(seconds: seconds);
    List<String> parts = d.toString().split(":");
    String str = '';
    if (int.parse(parts[0]) > 0) {
      str += "${parts[0]}:";
    }
    String secondsStr = parts[2].replaceFirst(RegExp("\\.[0-9]{6}"), '');
    str += "${parts[1]}:$secondsStr";
    return str;
  }

//  当前时间转北京时间
  static String getUtcDate() {
    return DateTime.now()
        .add(const Duration(hours: 8))
        .toUtc()
        .toString()
        .replaceFirst(" ", "T")
        .replaceFirst(RegExp('\\.[0-9A-Z]{7}'), "+08:00");
  }

  ///日期时间本地格式化
  static String utc2iso(String? formattedString) {
    if (formattedString == null || formattedString.isEmpty) return '';
    try {
      DateTime dateTime = DateTime.parse(formattedString).toLocal();
      String y = _fourDigits(dateTime.year);
      String m = _twoDigits(dateTime.month);
      String d = _twoDigits(dateTime.day);
      String h = _twoDigits(dateTime.hour);
      String min = _twoDigits(dateTime.minute);
      String sec = _twoDigits(dateTime.second);
      return "$y-$m-$d $h:$min:$sec";
    } catch (e) {
      return '';
    }
  }

  ///2020-11-26T17:44:45.000Z
  static String format2utc(DateTime dateTime) {
    String y = _fourDigits(dateTime.year);
    String m = _twoDigits(dateTime.month);
    String d = _twoDigits(dateTime.day);
    String h = _twoDigits(dateTime.hour);
    String min = _twoDigits(dateTime.minute);
    String sec = _twoDigits(dateTime.second);
    String ms = _threeDigits(dateTime.millisecond);
    return "$y-$m-${d}T$h:$min:$sec.${ms}Z";
  }

  static String _fourDigits(int n) {
    int absN = n.abs();
    String sign = n < 0 ? "-" : "";
    if (absN >= 1000) return "$n";
    if (absN >= 100) return "${sign}0$absN";
    if (absN >= 10) return "${sign}00$absN";
    return "${sign}000$absN";
  }

  static String _threeDigits(int n) {
    if (n >= 100) return "$n";
    if (n >= 10) return "0$n";
    return "00$n";
  }

  static String _twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  ///utc 转 年月日
  static String utcTurnYear(String? date, {String? char}) {
    if (date!.isEmpty) return '';
    DateTime dateTime = DateTime.parse(date).toLocal();
    String y = _fourDigits(dateTime.year);
    String m = _twoDigits(dateTime.month);
    String d = _twoDigits(dateTime.day);
    if(char?.isNotEmpty == true){
      return "$y$char$m$char$d ";
    }
    return "$y-$m-$d ";
  }

  ///utc 转 月日
  static String utc2MonthDay(String date) {
    if (date.isEmpty) return '';
    try {
      DateTime dateTime = DateTime.parse(date).toLocal();
      String m = _twoDigits(dateTime.month);
      String d = _twoDigits(dateTime.day);
      return "$m-$d ";
    } catch (e) {
      return '';
    }
  }

  ///计算时间差值
  static String calTime(String date, DateTime? serverTime) {
    //解析时间
    var time = DateTime.parse(date).toLocal();
    //计算时间差
    var difference = time.difference(serverTime ?? DateTime.now());

    String day = difference.inDays.toString();
    String hours = (difference.inHours % 24).toString();
    String minutes = (difference.inMinutes % 60).toString();
    return "${day}_${hours}_$minutes";
  }

  ///日期时间本地格式化
  static String utc2iso2(String formattedString) {
    if (formattedString.isEmpty) return '';
    try {
      DateTime dateTime = DateTime.parse(formattedString).toLocal();
      String m = _twoDigits(dateTime.month);
      String d = _twoDigits(dateTime.day);
      String h = _twoDigits(dateTime.hour);
      String min = _twoDigits(dateTime.minute);
      return "$m-$d $h:$min";
    } catch (e) {
      return '';
    }
  }

  ///utc 转 年月日
  static String utcTurnYear2(String? date, {String char = "/"}) {
    if (date?.isNotEmpty != true) return '';
    DateTime dateTime = DateTime.parse(date!).toLocal();
    String y = _fourDigits(dateTime.year);
    String m = _twoDigits(dateTime.month);
    String d = _twoDigits(dateTime.day);
    return "$y$char$m$char$d ";
  }

  static bool compareTime(String date) {
    if (date.isEmpty) return false;

    try {
      DateTime dateNowTime = DateTime.now().toLocal();
      String y = _fourDigits(dateNowTime.year);
      String m = _twoDigits(dateNowTime.month);
      String d = _twoDigits(dateNowTime.day);

      String nowDateStr = "$y-$m-$d";
      String newDateStr =
          DateTime.fromMillisecondsSinceEpoch(int.parse(date)).toString();
      String dateStr = utcTurnYear(newDateStr).trim();
      return nowDateStr == dateStr;
    } catch (e) {
      // l.e("compareTime--->" ,"$e");
    }
    return false;
  }

  ///格式化为年月日-yyyy-MM-dd
  static String formatDateYYMMDD(DateTime? dateTime) {
    if (dateTime == null) {
      return "";
    }
    return formatDate(dateTime, [yyyy, '-', mm, '-', dd]);
  }


  static String showDateDesc(String dtStr) {
    if ((dtStr.isEmpty)) return "刚刚";
    var curSeconds = DateTime.now().millisecondsSinceEpoch / 1000;
    var oldSeconds = DateTime.parse(dtStr).millisecondsSinceEpoch / 1000;

    var diff = curSeconds - oldSeconds;
    if (diff < 60) return "刚刚";
    if (diff < 3600) return "${diff ~/ 60}分钟";
    if (diff < 3600 * 24) return "${diff ~/ 3600}小时内";
    var showTime = diff ~/ (3600 * 24);
    if (showTime < 4) return "$showTime天前";
    return "3天前";
  }

    static String showMilliSecondsDateDesc(int millisecondsSinceEpoch) {
    if ((millisecondsSinceEpoch == 0)) return "刚刚";
    var curSeconds = DateTime.now().millisecondsSinceEpoch / 1000;
    var oldSeconds = millisecondsSinceEpoch / 1000;

    var diff = curSeconds - oldSeconds;
    if (diff < 60) return "刚刚";
    if (diff < 3600) return "${diff ~/ 60}分钟";
    if (diff < 3600 * 24) return "${diff ~/ 3600}小时内";
    var showTime = diff ~/ (3600 * 24);
    if (showTime < 4) return "$showTime天前";
    return "3天前";
  }
}
