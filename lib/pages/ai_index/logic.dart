import 'package:comics_app/common/apis/ai_api.dart';
import 'package:comics_app/common/entities/ai/ai_models.dart';
import 'package:get/get.dart';

import 'state.dart';

class AiIndexLogic extends GetxController {
  final state = AiIndexState();

  @override
  void onInit() {
    super.onInit();
    loadHome();
  }

  /// 拉取首页：余额 / 规则列表。
  Future<void> loadHome() async {
    state.loading = true;
    update(['modelList']);
    final AiClientHomeVo? home = await AIApi.getHome();
    state.homeModel = home;
    state.displayRules = AiIndexState.sortedEnabledRules(home?.rules);
    state.loading = false;
    update(['modelList', 'top']);
  }
}
