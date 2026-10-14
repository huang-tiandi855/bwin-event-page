import 'package:comics_app/pages/bookshelf/bookshelf_logic.dart';
import 'package:comics_app/pages/mine_index/logic.dart';
import 'package:comics_app/pages/welfare/welfare_logic.dart';
import 'package:get/get.dart';

import 'application_logic.dart';

class ApplicationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ApplicationLogic());
    Get.lazyPut(() => WelfareLogic());
    Get.lazyPut(() => BookshelfLogic());
    // Get.lazyPut(() => MineLogic());
    Get.lazyPut(() => MineIndexLogic(), fenix: true);
    
  }
}
