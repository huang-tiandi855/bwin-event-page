import 'package:comics_app/common/apis/wallet.dart';
import 'package:comics_app/common/utils/logger.dart';
import 'package:get/get.dart';

///倒计时控制器
class CountdownController extends GetxController {
  static CountdownController get to => Get.find();
  Countdown _countdown = Countdown();

  void setCountdown(Countdown countdown) {
    _countdown = countdown;
  }

  Countdown get countdown => _countdown;

  ///获取新人倒计时
  Future<bool> vipCutDownReq() async {
    try {
      Countdown countdown = await WalletApi.vipCutDownReq();
      setCountdown(countdown);
      return true;
    } catch (e) {
      l.d("获取新人倒计时异常：$e");
    }
    return false;
  }
}

class Countdown {
  int? countdownSec;
  String? copywriting;

  Countdown({this.countdownSec = 0});

  Countdown.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      countdownSec = json['countdownSec'] ?? 0;
      copywriting = json['copywriting'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['countdownSec'] = countdownSec;
    data['copywriting'] = copywriting;
    return data;
  }
}
