import 'package:get/get.dart';

import '../../../common/entities/annoumsg.dart';

class WelfareDetailsState {
  AnnouList? annouList;
  String? id;
  WelfareDetailsState() {
    ///Initialize variables
    annouList = Get.arguments?['annouList'];
    id = Get.arguments?['id'];
  }
}
