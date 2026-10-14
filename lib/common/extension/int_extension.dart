extension IntFormat on int {
  //人性化数量
  String get humanizeFormat {
    int value = this;
    if (value <= 0 || value.isNaN) {
      return '0';
    } else if (value > 0 && value < 1000) {
      return value.toString();
    } else if (value >= 1000 && value < 10000) {
      String format = (value / 1000).toStringAsFixed(1);
      return '${format}k';
    } else if (value >= 10000 && value < 100000000) {
      String format = (value / 10000).toStringAsFixed(1);
      return '${format}w';
    } else {
      String format = (value / 100000000).toStringAsFixed(1);
      return '$format億';
    }
  }
}

extension NumExt on num {
  /// 保留小数点后几位，且不四舍五入
  String toStringAsFixedWithoutRound(int fractionDigits) {
    String value = toString();
    if (fractionDigits == 0) {
      return value.substring(0, value.lastIndexOf('.'));
    }
    return value.substring(0, value.lastIndexOf('.') + fractionDigits + 1);
  }

  String get humanizeFormat2 {
    num value = this;
    if (value <= 0 || value.isNaN) {
      return '0';
    } else if (value > 0 && value < 10000) {
      return value.toString();
    } else {
      String format = (value / 10000).toStringAsFixedWithoutRound(1);
      return '${format}w';
    }
  }
}
