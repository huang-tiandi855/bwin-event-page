import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class MsgSendState {
  int lever = 1; //1 2 1级评论还是二级评论
  int lever2ListIndex = -1; // 二级评论索引
  RxString hintText = "请输入你的文字内容".obs;
  TextEditingController textEditingController = TextEditingController();
  bool isSendList = true;
  VoidCallback? commentSuccessFun;
  MsgSendState() {
    ///Initialize variables
  }
}
