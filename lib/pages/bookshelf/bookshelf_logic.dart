import 'package:comics_app/common/utils/toast_util.dart';
import 'package:get/get.dart';
import '../../common/apis/bookShelf.dart';
import '../../common/http/base_resp_bean.dart';
import 'bookshelf_state.dart';

class BookshelfLogic extends GetxController {
  final BookshelfState state = BookshelfState();

  //编辑
  void edit() {
    state.isEdit.value = !state.isEdit.value;
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  //取消收藏
  Future<bool> unCollect(int kind, String id) async {
    try {
      Map<String, dynamic> data = {"kind": kind, "mediaID": id};
      BaseRespBean baseRespBean = await BookApi.cartoonUncollect(data);
      if (baseRespBean.isSuccess) return true;
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> cancelCollectResponse(String id, {String type = 'img'}) async {
    BaseRespBean baseRespBean = BaseRespBean(0);
    // BaseRespBean baseRespBean = await CircleApi.tagCollect(data);
    if (baseRespBean.isSuccess) {
      return true;
    } else {
      showToast(msg: baseRespBean.tip ?? '');
    }
    return false;
  }
}
