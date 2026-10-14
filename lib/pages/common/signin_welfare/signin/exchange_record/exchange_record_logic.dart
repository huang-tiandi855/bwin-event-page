import 'package:comics_app/common/apis/signin_apis.dart';
import 'package:get/get.dart';

import 'exchange_record_state.dart';

class ExchangeRecordLogic extends GetxController {
  final ExchangeRecordState state = ExchangeRecordState();

  @override
  void onInit() {
    super.onInit();
    final dynamic args = Get.arguments;
    if (args is Map && args['currentPoints'] is int) {
      state.currentPoints = args['currentPoints'] as int;
    }
    getExchangeRecordList();
  }

  Future<void> getExchangeRecordList() async {
    try {
      state.records = await SignInApis.getPointsExchangeRecordList();
    } finally {
      update();
    }
  }
}
