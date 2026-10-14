// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'media_info_entity.dart';

class ReaderChapterModel {
  late String id;
  late String mediaID;
  late int episodeNumber;
  late int listenPermission;
  late int price;
  late String name;
  late String text;
  late int status;
  late bool isActive;
  late bool hasPaid;

  late List<Map<String, int>> pageOffsets;
  int? index;

  // 付费类型
  // 视频付费类型+用户身份结合判断
  int get needPermission {
    // 至尊会员 返回免费
    // if (UserStore.to.getUserInfoModel?.videoFreeExpiration != null &&
    //     isBeforeToday(UserStore.to.getUserInfoModel?.videoFreeExpiration)) {
    //   return 2;
    // } else {
    //   if (hasPaid) {
    //     return 2;
    //   } else {
    //     // vip视频
    //     if (listenPermission == 0 && UserStore.to.isVip()) {
    //       return 2;
    //     } else if (listenPermission == 1 && price == 0) {
    //       // 金豆视频
    //       // 当前用户是vip，且vip应付金豆 = 0时免费观看
    //       // 当前用户已经购买过该视频时免费观看
    //       return 2;
    //     }
    //   }

    //   return listenPermission;
    // }
    return 1;
  }

  bool isBeforeToday(String time) {
    if (time != "0001-01-01T00:00:00Z") {
      var startDate = time;
      var endDate = DateTime.now();
      return DateTime.parse(startDate).isBefore(endDate);
    } else {
      return true;
    }
  }

  ReaderChapterModel({
    required this.id,
    required this.index,
    required this.mediaID,
    required this.episodeNumber,
    required this.listenPermission,
    required this.price,
    required this.name,
    required this.text,
    required this.status,
    required this.isActive,
    required this.hasPaid,
    required this.pageOffsets,
  });

  ReaderChapterModel.fromJson(MediaInfoContents data) {
    id = data.id ?? "";
    mediaID = data.mediaID ?? "";
    episodeNumber = data.episodeNumber ?? 0;
    listenPermission = data.listenPermission ?? 0;
    price = data.price ?? 0;
    name = data.name ?? "";
    text = '　　${data.text ?? ""}';
    text = text.replaceAll(RegExp("\n\n\n|\n\n|\n"), "\n    ");
    status = data.status ?? 0;
    isActive = data.isActive ?? false;
    hasPaid = data.hasPaid ?? false;
  }

  String stringAtPageIndex(int index) {
    var offset = pageOffsets[index];
    return text.substring(offset['start']!, offset['end']);
  }

  int get pageCount {
    return pageOffsets.length;
  }
}
