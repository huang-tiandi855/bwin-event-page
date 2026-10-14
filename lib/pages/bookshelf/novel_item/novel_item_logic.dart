import 'package:comics_app/common/store/store.dart';
import 'package:get/get.dart';

import '../../../common/apis/bookShelf.dart';
import '../../../common/entities/media_list_entity.dart';
import '../../../common/http/base_resp_bean.dart';
import 'novel_item_state.dart';

class NovelItemLogic extends GetxController {
  final NovelItemState state = NovelItemState();

  @override
  void onInit() {
    // TODO: implement onReady
    super.onInit();
    // getCartoonHot();
    getData();

    Map map = {};

    map["链路"] = "书架-小说";

    ConfigStore.to.trackData('小说浏览', map);
  }

  onRefresh() async {
    state.pageNumber = 1;
    state.list.clear();
    getData();

    state.wantPageNumber = 1;
    state.wantToSeeList.clear();
    // getCartoonHot();
  }

  onLoad() async {
    if (state.isCollectionEmpty) {
      state.wantPageNumber++;
      getCartoonHot();
    } else {
      state.pageNumber++;
      getData();
    }
  }

  //获取收藏数据
  void getData() async {
    try {
      Map<String, dynamic> data = {"kind": 4, "page": state.pageNumber, "pageSize": state.pageSize};
      BaseRespBean baseRespBean = await BookApi.getCartoonCollectList(data);
      if (baseRespBean.isSuccess) {
        MediaListEntity mediaListEntity = MediaListEntity.fromJson(baseRespBean.data);

        state.list.addAll(mediaListEntity.mediaList ?? []);

        /*bool hasMore = (mediaListEntity.mediaList?.length ?? 0) < state.pageSize
            ? false
            : true;*/

        bool hasMore = mediaListEntity.hasNext!;

        state.pullRefreshController.requestSuccess(isFirstPageNum: state.pageNumber == 1);

        //猜你想看请求
        if (!hasMore) {
          await getCartoonHot();
        } else {
          update(['want']);
        }

        state.isCollectionEmpty = !mediaListEntity.hasNext!;

        update(['list']);
        return;
      }
      state.pullRefreshController.requestFail(isFirstPageNum: state.pageNumber == 1);
    } catch (e) {
      state.pullRefreshController.requestFail(isFirstPageNum: state.pageNumber == 1);
    }
  }

  //获取猜你想看
  getCartoonHot() async {
    try {
      Map<String, dynamic> data = {
        "kind": state.kind.index,
        "page": state.wantPageNumber,
        "pageSize": state.wantPageSize,
      };
      BaseRespBean baseRespBean = await BookApi.getCartoonHot(data);
      if (baseRespBean.isSuccess) {
        MediaListEntity mediaListEntity = MediaListEntity.fromJson(baseRespBean.data);

        state.wantToSeeList.addAll(mediaListEntity.mediaList ?? []);

        bool hasMore = (mediaListEntity.mediaList?.length ?? 0) < state.pageSize ? false : true;

        bool isEmpty = (state.list.isEmpty && state.wantToSeeList.isEmpty) ? true : false;

        state.pullRefreshController
            .requestSuccess(isFirstPageNum: state.wantPageNumber == 1, hasMore: hasMore, isEmpty: isEmpty);

        update(['want']);
        return;
      }
      state.pullRefreshController.requestFail(isFirstPageNum: state.wantPageNumber == 1);
    } catch (e) {
      state.pullRefreshController.requestFail(isFirstPageNum: state.wantPageNumber == 1);
    }
  }
}
