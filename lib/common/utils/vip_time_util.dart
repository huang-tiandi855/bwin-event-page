// import 'package:comics_app/common/utils/text_util.dart';

import 'date_util.dart';

///刷新VIP时间
String getVipStringFromTime(String time, DateTime? nowTime) {
  nowTime = (nowTime ?? DateTime.now());

  // String result = DataFormats.calTime(DataFormats.utc2iso(time), nowTime);
  String vipTime = "";
  // List<String> timeList = result.split("_");
  if (time.length > 2) {
    vipTime = DataFormats.utcTurnYear(time);
    // if (int.parse(timeList[0]) > 3 ||
    //     (int.parse(timeList[0]) == 3 && int.parse(timeList[1]) > 0) ||
    //     (int.parse(timeList[0]) == 3 && int.parse(timeList[1]) == 0) &&
    //         int.parse(timeList[2]) > 0) {
    //   //大于3天
    //   var experidTime =
    //   TextUtil.isNotEmpty(time) ? DateTime.parse(time) : DateTime.now();
    //   if (experidTime.year - nowTime.year > 10) {
    //     vipTime = "VIP 永久" ;
    //   } else {
    //     vipTime = "VIP ${DataFormats.utcTurnYear(time)}";
    //   }
    // } else if (int.parse(timeList[0]) >= 1) {
    //   //大于等于1天，小于等于3天
    //   vipTime = "VIP 剩余${timeList[0]}天";
    // } else if (int.parse(timeList[1]) >= 1) {
    //   //一小时以上
    //   vipTime = "VIP 剩余${timeList[1]}小时";
    // } else {
    //   vipTime = "VIP 剩余1小时";
    // }
  }
  return vipTime;
}
