import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/widgets/common_dialog/need_vip_dialog.dart';
import 'package:get/get.dart';

import '../../../common/entities/chat/user_chat_record_dto.dart';
import 'state.dart';

class MessageCenterLogic extends GetxController {
  final state = MessageCenterState();

  /// 点击消息项（占位，后续接入业务）
  void onItemTap(MessageType type, UserChatRecordDto? item) {
    if (!UserStore.to.isVip()) {
      showNeedVipDialog(bodyLine1: '您还不是VIP无法私信');
      return;
    }
    Get.toNamed(AppRoutes.CHAT, arguments: {
      'otherId': item?.contactInfo?.id,
      'nickName': item?.contactInfo?.nickName,
      'avatar': item?.contactAvatar?.url,
    });
  }
}
