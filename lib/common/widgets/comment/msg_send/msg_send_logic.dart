import 'package:comics_app/common/apis/media_api.dart';
import 'package:comics_app/common/entities/post_entity.dart';
import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/widgets/comment/comment_view.dart';
import 'package:comics_app/common/widgets/comment/msg_send/widget/bottom_sheet_send_btn.dart';
import 'package:get/get.dart';

import 'msg_send_state.dart';

class MsgSendLogic extends GetxController {
  final MsgSendState state = MsgSendState();
  String id;
  PostList? postItem;
  CommentType type;
  bool isPop;
  String? sid;
  MsgSendLogic(this.id, this.postItem, this.type, this.isPop, {this.sid});

  Future updateShowSendStatus(bool? isLever2,{Function(String result)? result}) async {
    // if (isLever2 ?? false) {
    //   final commentDetailsState = Get.find<CommentDetailsLogic>().state;
    //   String userName = commentDetailsState.commentList.userName ?? "未知用户";
    //   state.lever = 2;
    //   state.hintText.value = "回复：@$userName";
    // }
    final r = await openSendMsgBtn(id: id, postItem: postItem, type: type,result: result);
    state.lever = 1;
    state.hintText.value = "请输入你的文字内容";
    return r;
  }

  void sendMsg() {
    if (state.lever == 1) {
      sendLever1();
    }
    // if (state.lever == 2) {
    //   sendLever2();
    // }
  }

  bool judgeInputText() {
    String text = state.textEditingController.text.trim();
    if (text.isEmpty) {
      showToast(msg: "请输入内容");
      return false;
    }
    return true;
  }

  ///发送评论
  ///
  /// 走 [MediaApi.sendComment]（`POST cms/vod/comment/add`），与拉取列表的
  /// [MediaApi.getVodCommentList] 同一套 vod 评论体系。业务上 `id` 即视频
  /// `vid`，需可解析为 int，否则直接 toast 拒绝。
  ///
  /// **注意（产品需求）**：评论需后台审核后才会出现在列表里，因此发送成功后
  /// 这里不再做任何「乐观插入 / 评论数 +1」的处理：
  /// - 不再调用 [MsgSendState.commentSuccessFun] 触发外部计数 +1；
  /// - 不再现场拼 [VodCommentItemModel] 插入 [CommentPopLogic] / [CommentLogic]
  ///   的列表头；
  /// - 不再修改 [PostList.commentCount]；
  /// 只清空输入框、提示「发送成功，等待审核！」并关闭面板。
  void sendLever1() async {
    String text = state.textEditingController.text.trim();
    if (text.isEmpty) {
      showToast(msg: "请输入内容");
      return;
    }
    final int? vid = int.tryParse(id);
    if (vid == null) {
      showToast(msg: "视频信息异常");
      return;
    }
    BaseRespBean baseRespBean =
        await MediaApi.sendComment(vid: vid, content: text);
    if (baseRespBean.isSuccess) {
      state.textEditingController.text = "";
      showToast(msg: "发送成功，等待审核！");
      Get.back();
    }
  }
}
