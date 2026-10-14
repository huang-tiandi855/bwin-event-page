import 'package:comics_app/common/entities/pagination_model.dart';
import 'package:comics_app/common/entities/video_model/video_model.dart';
import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:get/get.dart';

import '../../../common/apis/bookShelf.dart';
import '../../../common/entities/media_list_entity.dart';
import '../../../common/http/base_resp_bean.dart';
import 'photo_item_state.dart';

class PhotoItemLogic extends GetxController {
  final PhotoItemState state = PhotoItemState();

  @override
  void onInit() {
    // TODO: implement onReady
    super.onInit();
    getData();

    Map map = {};

    map["链路"] = "书架-写真";

    ConfigStore.to.trackData('写真浏览', map);
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
      BaseRespBean baseRespBean = BaseRespBean(0);
      // BaseRespBean baseRespBean = await CircleApi.getCollectList(data);
      // if (baseRespBean.isSuccess) {

      //   bool hasMore = model.hasNext;

      //   state.pullRefreshController.requestSuccess(
      //       isFirstPageNum: state.pageNumber == 1,
      //       hasMore: hotTopicEntity.hasNext ?? false,
      //       isEmpty: isEmpty);
      //   update();
      //   return;
      if (baseRespBean.isSuccess) {
        final model = PaginationModel.fromJson(itemFactory: VideoModel.fromJson, json: baseRespBean.data);

        state.list.addAll(model.list);

        /*bool hasMore = (mediaListEntity.mediaList?.length ?? 0) < state.pageSize
            ? false
            : true;*/

        bool hasMore = model.hasNext;

        state.pullRefreshController.requestSuccess(isFirstPageNum: state.pageNumber == 1);

        //猜你想看请求
        if (!hasMore) {
          if (state.list.isEmpty) {
            await getCartoonHot();
          }
        } else {
          update(['want']);
        }

        state.isCollectionEmpty = !model.hasNext;

        update();
        return;
      }
      state.pullRefreshController.requestFail(isFirstPageNum: state.pageNumber == 1);
    } catch (e) {
      state.pullRefreshController.requestFail(isFirstPageNum: state.pageNumber == 1);
    }
  }

  cancelCollectResponse(int index) async {
    final model = state.list[index];
    BaseRespBean baseRespBean = BaseRespBean(0);
    // BaseRespBean baseRespBean = await CircleApi.tagCollect(data);
    if (baseRespBean.isSuccess) {
      showToast(msg: '取消收藏成功');
      state.list.remove(model);
      update();
    } else {
      showToast(msg: baseRespBean.tip ?? '');
    }

    // bool isOk = await logic.unCollect(kind, id);
    //                                 list.removeAt(index);
    //                                 if (isOk) {
    //                                   if (list.isEmpty) {
    //                                     bookShelfState.isEdit.value = true;
    //                                   }
    //                                   logic.update(['list']);
    //                                   showToast(msg: "移除成功");
    //                                   return;
    //                                 }
    //                                 showToast(msg: "删除失败");
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
