import 'package:comics_app/common/apis/media_api.dart';
import 'package:comics_app/common/entities/media_info.dart';
import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/values/enum.dart';
import 'package:comics_app/common/widgets/golden_beans_buying.dart';
import 'package:comics_app/common/widgets/memberPaying.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../common/apis/bookShelf.dart';
import '../../../common/http/base_resp_bean.dart';
import '../../../common/utils/utils.dart';
import 'portray_detail_state.dart';

class PortrayDetailLogic extends GetxController {
  final PortrayDetailState state = PortrayDetailState();

  @override
  void onInit() {
    super.onInit();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    getMediaInfo(state.mediaInfoId!);
    state.scrollController.addListener(() async {
      await checkPermission();
    });
  }

  Future<void> checkPermission() async {
    ///vip
    if (state.mediaInfo!.data!.permission == 0 &&
        !UserStore.to.isVip() &&
        !state.mediaInfo!.data!.mediaStatus!.hasPaid!) {
      if (!state.showDialog) {
        state.showDialog = true;
        await openMemberPaying(
                isShowCoupon: true,
                productType: 24,
                id: state.mediaInfo?.data!.id.toString(),
                title: state.mediaInfo?.data!.title)
            .then((value) {
          if (value == PaySuccess.exchangeSuccessFullly) {
            getMediaInfo(state.mediaList[state.index].id.toString());
          }
          state.scrollController.jumpTo(0);
          state.showDialog = false;
        });
      }
    }

    ///金豆
    if (state.mediaInfo!.data!.permission == 1 &&
        state.mediaInfo!.data!.price != 0 &&
        !state.mediaInfo!.data!.mediaStatus!.hasPaid!) {
      if (!state.showDialog) {
        state.showDialog = true;
        await openGoldenBeansBuying(
          id: state.mediaInfo!.data!.id.toString(),
          title: state.mediaInfo!.data!.title.toString(),
          price: state.mediaInfo!.data!.price ?? 0,
          productType: 24,
          isShowCoupon: true,
        ).then((value) {
          if (value == PaySuccess.exchangeSuccessFullly ||
              value == PaySuccess.successfulPurchase) {
            getMediaInfo(state.mediaList[state.index].id.toString());
          }
          state.scrollController.jumpTo(0);
          state.showDialog = false;
        });
      }
    }
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    PaintingBinding.instance.imageCache.clear();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    HistoryOperation.getInstance()?.add(
        info: state.mediaInfo,
        episode: 1,
        recordType: HistoryRecordType.picture);
  }

  void hideMenu() {
    state.isMenuVisiable.value = false;
  }

  void onTap() {
    state.isMenuVisiable.value = true;
  }

  //初始化数据
  void getMediaInfo(String mediaInfoId) async {
    final BaseRespBean resp = await MediaApi.getMediaInfo(mediaInfoId);
    state.mediaInfo = MediaInfo.fromJson(resp.toJson());
    state.title = state.mediaInfo!.data!.title.toString();
    update();
  }

  void lastPortray() async {
    if (state.index == 0) {
      showToast(msg: "没有更多了");
    } else {
      state.index = state.index - 1;
      final BaseRespBean resp = await MediaApi.getMediaInfo(
          state.mediaList[state.index].id.toString());
      state.mediaInfo = MediaInfo.fromJson(resp.toJson());

      state.title = state.mediaInfo!.data!.title.toString();

      update();

      state.scrollController.jumpTo(0);

      clear();
    }
  }

  void nextPortray() async {
    printInfo(
        info:
            "${state.mediaList.isNotEmpty}====${state.index}====${state.mediaList.length}");
    if (state.mediaList.isNotEmpty != true ||
        state.index == state.mediaList.length - 1) {
      showToast(msg: "没有更多了");
    } else {
      state.index = state.index + 1;
      final BaseRespBean resp = await MediaApi.getMediaInfo(
          state.mediaList[state.index].id.toString());
      state.mediaInfo = MediaInfo.fromJson(resp.toJson());

      state.title = state.mediaInfo!.data!.title.toString();

      update();

      state.scrollController.jumpTo(0);

      clear();
    }
  }

  void clear() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  cartoonCollcet() async {
    try {
      Map<String, dynamic> data = {
        "kind": state.mediaInfo?.data?.kind ?? 0,
        "mediaID": state.mediaInfo?.data?.id
      };
      if (state.mediaInfo?.data?.mediaStatus?.hasCollected ?? false) {
        BaseRespBean baseRespBean = await BookApi.cartoonUncollect(data);
        if (baseRespBean.isSuccess) {
          showToast(msg: "取消收藏");
          state.mediaInfo?.data?.mediaStatus?.hasCollected = false;
          update(["collected"]);
          return;
        }
        showToast(msg: baseRespBean.tip ?? "收藏失败");
      } else {
        BaseRespBean baseRespBean = await BookApi.cartoonCollcet(data);
        if (baseRespBean.isSuccess) {
          showToast(msg: "收藏成功");
          state.mediaInfo?.data?.mediaStatus?.hasCollected = true;
          update(["collected"]);
          return;
        }
        showToast(msg: baseRespBean.tip ?? "收藏失败");
      }
    } catch (e) {
      showToast(msg: "收藏失败");
    }
  }
}
