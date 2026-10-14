import 'package:get/get.dart';

class SigninWelfareState {
  static const List<String> primaryTabs = ['代理赚钱', '签到', '应用推荐'];
  int currentTab = 1;
  SigninWelfareState() {
    currentTab = Get.arguments?['index'] as int? ?? 1;
  }
}
