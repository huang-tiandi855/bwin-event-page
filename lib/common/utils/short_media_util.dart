import 'package:comics_app/common/entities/module_detail_model/all_media_info_model.dart';
import 'package:comics_app/pages/short_video_main/skits_play/short_media_play_page.dart';
import 'package:get/get.dart';

import 'history_record_util.dart';

class ShortMediaUtil {
  static jumpBySingleMediaId(String id) async {
    final record = await MediaPlayRecord().getSkitsRecords();
    Get.to(() => const ShortMediaPlayPage(), arguments: {
      'entry': 1,
      'info': [AllMediaInfoModel(id: id)],
      'selectIndex': record[id]?.episode ?? 0,
    });
  }
}
