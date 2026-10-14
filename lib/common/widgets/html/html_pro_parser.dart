import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

class HtmlProParser {
  static Color? spanBg(String? value) {
    if (value?.isNotEmpty == true) {
      try {
        String? targetValue = value?.toLowerCase();
        List<String>? splitArr = targetValue?.split(":");
        if (splitArr?.length == 2 && splitArr?.last.contains("rgb") == true) {
          String? rgbStr = splitArr?.last;
          rgbStr = rgbStr?.replaceAll("rgb(", "");
          rgbStr = rgbStr?.replaceAll(");", "");
          List<String>? rgbArr = rgbStr?.split(",");
          if (rgbArr?.length == 3) {
            int? rValue = int.tryParse(rgbArr![0]);
            int? gValue = int.tryParse(rgbArr[1]);
            int? bValue = int.tryParse(rgbArr[2]);
            return Color.fromRGBO(rValue ?? 0, gValue ?? 0, bValue ?? 0, 1);
          }
        }
      } catch (_) {
        // 解析失败回落到 null
      }
    }
    return null;
  }

  static AlignmentGeometry alignment(String value) {
    if (value == "text-align:center;") {
      return Alignment.topCenter;
    } else if (value == "text-align:right;") {
      return Alignment.topRight;
    } else {
      return Alignment.topLeft;
    }
  }

  static WrapAlignment wrapAlignment(String value) {
    if (value == "text-align:right;") {
      return WrapAlignment.end;
    } else if (value == "text-align:center;") {
      return WrapAlignment.center;
    } else {
      return WrapAlignment.start;
    }
  }

  static double? lineHeight(String? value) {
    try {
      if (value?.contains("line-height:") == true) {
        String? sizeStr = value?.replaceAll("line-height:", "");
        sizeStr = sizeStr?.replaceAll(";", "");
        double? height = double.tryParse(sizeStr ?? "");
        return height;
      }
    } catch (_) {
      // 解析失败回落到 null
    }
    return null;
  }
}
